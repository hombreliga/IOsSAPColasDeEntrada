//
//  ConsultaViewController.m
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import "ConsultaViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"
#import "DetalleController.h"
#import "sqlite3.h"

@interface ConsultaViewController ()
{
    NSXMLParser *xmlLector;
    NSMutableString *currentElementValue;
    
    NSString *statusConsulta;
    NSMutableDictionary * currentDic;
    NSMutableArray *arrColas;
    NSString *estatusErr;
    NSString *estatusWa;
    NSString *nivel2;
    
    AppDelegate * objGlobal;
    
    int flag;
    NSOperationQueue *queue;
    
    // DB Variables
    NSString *docsDir;
    NSArray *dirPaths;
    
    NSString * dbPath;
    sqlite3 * historicoBD;
    BOOL seAbrioBD;
    BOOL existeTabla;
    
    char * errMsg;
    NSString * sql_stmt;
}
@end

@implementation ConsultaViewController
@synthesize indicador;
@synthesize tabla;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    objGlobal = [UIApplication sharedApplication].delegate;
    arrColas  = [[NSMutableArray alloc] init];
    objGlobal.strID = [[NSString alloc] init];
    objGlobal.strDestino = [[NSString alloc] init];
    objGlobal.strNumero = [[NSString alloc] init];
    objGlobal.strEstatus = [[NSString alloc] init];
    objGlobal.strFecha = [[NSString alloc] init];
    objGlobal.strHora = [[NSString alloc] init];
    objGlobal.strTxtError = [[NSString alloc] init];
    objGlobal.strTxtID = [[NSString alloc] init];
    
    [self iniciaVars];
    [self llenarTablaBG];
    
}
-(void)viewDidAppear:(BOOL)animated{
    //[queue waitUntilAllOperationsAreFinished];
    //[self llamarWS];
    
    //[self pintarTabla];
    //[self.tabla scrollsToTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)llenarTablaBG{
    queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(llamarWS) object:nil];
    
    
    [queue addOperation:operation];
    
    
    
}
-(void) pintarTabla
{
    if (flag == 1) {
        if ([arrColas count] >0) {
            [tabla reloadData];
        }else{
            [self Alerta:@"Mensaje" Mensaje:@"No existen registros, modifique su selección." TextoBtnCancel:@"Ok"];
        }
    }else{
        [self Alerta:@"Mensaje" Mensaje:@"Error al llamar al WS intente de nuevo." TextoBtnCancel:@"Ok"];
    }
}
- (void) iniciarActivity{
	[self.indicador startAnimating];
    [self.indicador setHidden:NO];
    return;
}

- (void) finalizarActivity{
    [self.indicador setHidden:YES];
    [self.indicador stopAnimating];
    return;
}

-(void)Alerta:(NSString *)titulo Mensaje:(NSString *)mensaje TextoBtnCancel:(NSString *)txtbtnCancel{
    [[[UIAlertView alloc] initWithTitle:titulo message:mensaje delegate:self cancelButtonTitle:txtbtnCancel otherButtonTitles:nil] show];
}

- (void) llamarWS{
    flag = 0;
    [self performSelectorOnMainThread:@selector(iniciarActivity) withObject:nil waitUntilDone:YES];
    //[self iniciarActivity];
    /* Primera Parte. Obtener datos */

    //Definicion de variables del WS
    NSString *stringURL = @"http://omerpqas.omnilife.com:8000/sap/bc/srt/rfc/sap/ztrfc_qin_overview/400/ztrfc_qin_overview/ztrfc_qin_overview";
    NSString *stringVars = @"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:sap-com:document:sap:soap:functions:mc-style\"><soapenv:Header/><soapenv:Body><urn:TrfcQinOverview><Client>%@</Client><Qname>%@</Qname><Qtable/><Qview/></urn:TrfcQinOverview></soapenv:Body></soapenv:Envelope>";
    
    
    stringVars = [NSString stringWithFormat:stringVars,objGlobal.strCliente,objGlobal.strCola];
    NSLog(@"cadena de envio %@\n\n",stringVars);
    
    //Definicion de variables para coneccion.
    NSString* varLen = [NSString stringWithFormat:@"%lu",(unsigned long)[stringVars length]];
    NSURL* tmpURL = [[NSURL alloc] initWithString:stringURL ] ;
    NSMutableURLRequest* peticion = [NSMutableURLRequest requestWithURL:tmpURL];
    [peticion setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [peticion setValue:@"text/xml;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [peticion setValue:@"" forHTTPHeaderField:@"SOAPAction"];
    [peticion setValue:varLen forHTTPHeaderField:@"Content-Length"];
    [peticion setValue:@"omerpqas.omnilife.com:8000" forHTTPHeaderField:@"Host"];
    [peticion setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [peticion setValue:@"Apache-HttpClient/4.1.1 (java 1.5)" forHTTPHeaderField:@"User-Agent"];
    [peticion setValue:@"Basic Q09NRUNDMDE6LjEzNTdvbW5p" forHTTPHeaderField:@"Authorization"];
    [peticion setHTTPMethod:@"POST"];
    [peticion setHTTPBody:[stringVars dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Ejecucion de la peticion
    NSData  *tmpData  = [NSURLConnection sendSynchronousRequest:peticion returningResponse:NULL error:NULL];
    NSString *tmpResp = [[NSString alloc] initWithData:tmpData encoding:NSUTF8StringEncoding];
    NSLog(@"RESPUESTA WS: \n\n%@\n\n",tmpResp);
    
    //Depuracion y presentacion de datos
    tmpResp = [self textToHtml:tmpResp];
    NSArray *aCadenas = [tmpResp componentsSeparatedByString:@"</Qtable>"];
    if([aCadenas count] > 1){
        aCadenas = [[aCadenas objectAtIndex:1] componentsSeparatedByString:@"</n0:TrfcQinOverviewResponse>"];
    }
    NSString * xmlOUTPUT = [aCadenas objectAtIndex:0];
    NSLog(@"Respuesta xmlOUTPUT: \n\n%@\n\n", xmlOUTPUT);
   
    
    /* Segunda parte. Pasar datos XML a Diccionario de Datos*/
    
    
    //Definicion de campos a procesar para el Diccionario de datos
 
    estatusErr = @"SYSFAIL,CPICERR,STOP,NOEXEC,ANORETRY";
    estatusWa = @"WAITING,WAITSTOP,FINISH,RETRY,AFINISH,ARETRY,MODIFY";
    
    nivel2 = @"Qname,Dest,Qdeep,Qstate,Fdate,Ftime,Errmess,Firsttid";
    
    //Conversion
    NSData* data = [xmlOUTPUT dataUsingEncoding:NSUTF8StringEncoding];
    xmlLector = [[NSXMLParser alloc] initWithData:data];
    xmlLector.delegate = self;

    if ([xmlLector parse]) {
        flag = 1;
    }
    
    //[self finalizarActivity];
    [self performSelectorOnMainThread:@selector(finalizarActivity) withObject:nil waitUntilDone:YES];
    
    [self performSelectorOnMainThread:@selector(pintarTabla) withObject:nil waitUntilDone:YES];
    
    return;
}


- (NSString*)textToHtml:(NSString*)htmlString {
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp;"  withString:@""];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    return htmlString;
}

/*-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}*/
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrColas count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CeldaCola";
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSMutableDictionary *dic = [arrColas objectAtIndex:indexPath.row];
    
    cell.nombreCola.text  = [dic objectForKey:@"Qname"];
    
    NSString *estatus = [dic objectForKey:@"Qstate"];
    cell.estatusCola.text = estatus;
    
    if ([estatusErr rangeOfString:estatus].location != NSNotFound){
        cell.backgroundColor = [UIColor redColor];
    }else if([estatusWa rangeOfString:estatus].location != NSNotFound){
        cell.backgroundColor = [UIColor yellowColor];
    }else{
        cell.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!currentElementValue){
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    }else{
        [currentElementValue appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    

    if ([elementName isEqualToString:@"item"]) {
        currentDic = [[NSMutableDictionary alloc] init];
        currentElementValue = [[NSMutableString alloc] init];
    }
    
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([nivel2 rangeOfString:elementName].location != NSNotFound){
        [currentDic setValue:currentElementValue forKey:elementName];
    }
    
    if ([elementName isEqualToString:@"item"]) {
        [arrColas addObject:currentDic];
        [self insertarHistorico:currentDic];
    }
    
    currentElementValue = nil;
}
-(void)insertarHistorico:(NSMutableDictionary *)dicDetalle
{
    if ([estatusErr rangeOfString:[dicDetalle objectForKey:@"Qstate"]].location != NSNotFound){
        NSString * sql_plantilla = @"";

        sql_plantilla = @"INSERT OR IGNORE INTO HISTORICO (FIRSTTID,QNAME,DEST,QDEEP,QSTATE,FDATE,FTIME,ERRMESS) values ('%@','%@','%@','%@','%@','%@','%@','%@')";
        sql_stmt = [NSString stringWithFormat:sql_plantilla,[dicDetalle objectForKey:@"Firsttid"],[dicDetalle objectForKey:@"Qname"], [dicDetalle objectForKey:@"Dest"],[dicDetalle objectForKey:@"Qdeep"],[dicDetalle objectForKey:@"Qstate"],[dicDetalle objectForKey:@"Fdate"],[dicDetalle objectForKey:@"Ftime"],[dicDetalle objectForKey:@"Errmess"]];
    
        if([self abrirBD] && existeTabla){
            if (sqlite3_exec(historicoBD, [sql_stmt UTF8String], NULL, NULL, &errMsg) == SQLITE_OK) {
            
            }else{
                [self Alerta:@"Mensaje" Mensaje:[NSString stringWithFormat:@"Falla Query: %s",errMsg] TextoBtnCancel:@"Ok"];
            }
            [self cerrarBD];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicDetalle = [arrColas objectAtIndex:indexPath.row];
    
    DetalleController *detalleCola = [self.storyboard instantiateViewControllerWithIdentifier:@"DetalleController"];
    
    objGlobal.strID = [dicDetalle objectForKey:@"Qname"];
    objGlobal.strDestino = [dicDetalle objectForKey:@"Dest"];
    objGlobal.strNumero = [dicDetalle objectForKey:@"Qdeep"];
    objGlobal.strEstatus = [dicDetalle objectForKey:@"Qstate"];
    objGlobal.strFecha = [dicDetalle objectForKey:@"Fdate"];
    objGlobal.strHora = [dicDetalle objectForKey:@"Ftime"];
    objGlobal.strTxtError = [dicDetalle objectForKey:@"Errmess"];
    objGlobal.strTxtID = [dicDetalle objectForKey:@"Firsttid"];
    
    [self.navigationController pushViewController:detalleCola animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)iniciaVars{
    // Directorio de Documentos
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // path del archivo de la base de datos
    dbPath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"historico.sqlite3"]];
    NSLog(@"path %@",dbPath);
    
    
    if([self abrirBD]){
        existeTabla = [self CrearTabla];
        [self cerrarBD];
    }
}



-(BOOL)abrirBD{
    
    BOOL resultado = NO;
    
    if (sqlite3_open([dbPath UTF8String], &historicoBD) == SQLITE_OK) {
        resultado = YES;
    }
    
    return resultado;
}

-(void)cerrarBD{
    sqlite3_close(historicoBD);
}


-(BOOL)CrearTabla{
    
    BOOL resultado = NO;
    
    //creacion de la tabla CONTACTOS si no existe.
    
    sql_stmt = @"CREATE TABLE IF NOT EXISTS HISTORICO (FIRSTTID TEXT PRIMARY KEY, QNAME TEXT, DEST TEXT, QDEEP TEXT,QSTATE TEXT,FDATE TEXT,FTIME TEXT,ERRMESS TEXT)";
    
    if (sqlite3_exec(historicoBD, [sql_stmt UTF8String], NULL, NULL, &errMsg) == SQLITE_OK) {
        resultado = YES;
    }else{
        NSLog(@"Falla query de creacion de tabla. %s",errMsg);
    }
    
    return resultado;
}

@end
