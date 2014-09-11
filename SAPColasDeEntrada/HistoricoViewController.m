//
//  HistoricoViewController.m
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import "HistoricoViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"
#import "DetalleController.h"
#import "sqlite3.h"

@interface HistoricoViewController ()
{
    AppDelegate * objGlobal;
    
    NSMutableDictionary * currentDic;
    NSMutableArray *arrColas;
    
    NSString *estatusErr;
    
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
    
    NSString *mesCons;
}

@end

@implementation HistoricoViewController
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
    
    mesCons = [self transfMes];
    [self iniciaVars];
    [self llenarTablaBG];
    
}

-(NSString *)transfMes
{
    NSString *mes;
    if ([objGlobal.strMes isEqualToString:@"Enero"]) {
        mes = @"01";
    }else if ([objGlobal.strMes isEqualToString:@"Febrero"]) {
        mes = @"02";
    }else if ([objGlobal.strMes isEqualToString:@"Marzo"]) {
        mes = @"03";
    }else if ([objGlobal.strMes isEqualToString:@"Abril"]) {
        mes = @"04";
    }else if ([objGlobal.strMes isEqualToString:@"Mayo"]) {
        mes = @"05";
    }else if ([objGlobal.strMes isEqualToString:@"Junio"]) {
        mes = @"06";
    }else if ([objGlobal.strMes isEqualToString:@"Julio"]) {
        mes = @"07";
    }else if ([objGlobal.strMes isEqualToString:@"Agosto"]) {
        mes = @"08";
    }else if ([objGlobal.strMes isEqualToString:@"Septiembre"]) {
        mes = @"09";
    }else if ([objGlobal.strMes isEqualToString:@"Octubre"]) {
        mes = @"10";
    }else if ([objGlobal.strMes isEqualToString:@"Noviembre"]) {
        mes = @"11";
    }else if ([objGlobal.strMes isEqualToString:@"Diciembre"]) {
        mes = @"12";
    }
    return mes;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)llenarTablaBG{
    queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(leerDB) object:nil];
    
    [queue addOperation:operation];

}

- (void) leerDB{
    flag = 0;
    [self performSelectorOnMainThread:@selector(iniciarActivity) withObject:nil waitUntilDone:YES];
    /* Primera Parte. Obtener datos */
    
    //Definicion de campos a procesar para el Diccionario de datos
    estatusErr = @"SYSFAIL,CPICERR,STOP,NOEXEC,ANORETRY";

    [self leerHistorico];
    
    [self performSelectorOnMainThread:@selector(finalizarActivity) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(pintarTabla) withObject:nil waitUntilDone:YES];
    
    return;
}

-(void)leerHistorico
{
    
    if([self abrirBD] && existeTabla){
        
        NSString *fechaLike = @"";
        fechaLike = [fechaLike stringByAppendingString:objGlobal.strAnio];
        fechaLike = [fechaLike stringByAppendingString:@"-"];
        fechaLike = [fechaLike stringByAppendingString:mesCons];
        fechaLike = [fechaLike stringByAppendingString:@"-%"];
        
        if ([objGlobal.strCola isEqualToString:@"*"]) {
            sql_stmt = @"select * from HISTORICO where FDATE LIKE '%@'";
            sql_stmt = [NSString stringWithFormat:sql_stmt,fechaLike];
        }else{
            sql_stmt = @"select * from HISTORICO where QNAME=%@ and FDATE LIKE '%@'";
            sql_stmt = [NSString stringWithFormat:sql_stmt,objGlobal.strCola,fechaLike];
        }
        
        sqlite3_stmt *recordset;
        
        if (sqlite3_prepare_v2(historicoBD, [sql_stmt UTF8String], -1, &recordset, nil) == SQLITE_OK) {
            flag = 1;
            while (sqlite3_step(recordset) == SQLITE_ROW) {
                currentDic = [[NSMutableDictionary alloc] init];
                
                char *firstId = (char *) sqlite3_column_text(recordset, 0);
                char *qName = (char *) sqlite3_column_text(recordset, 1);
                char *dest = (char *) sqlite3_column_text(recordset, 2);
                char *qDeep = (char *) sqlite3_column_text(recordset, 3);
                char *qState = (char *) sqlite3_column_text(recordset, 4);
                char *fDate = (char *) sqlite3_column_text(recordset, 5);
                char *fTime = (char *) sqlite3_column_text(recordset, 6);
                char *errmess = (char *) sqlite3_column_text(recordset, 7);
                
                [currentDic setValue:[[NSMutableString alloc] initWithCString:firstId encoding:NSUTF8StringEncoding] forKey:@"Firsttid"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:qName encoding:NSUTF8StringEncoding] forKey:@"Qname"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:dest encoding:NSUTF8StringEncoding] forKey:@"Dest"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:qDeep encoding:NSUTF8StringEncoding] forKey:@"Qdeep"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:qState encoding:NSUTF8StringEncoding] forKey:@"Qstate"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:fDate encoding:NSUTF8StringEncoding] forKey:@"Fdate"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:fTime encoding:NSUTF8StringEncoding] forKey:@"Ftime"];
                [currentDic setValue:[[NSMutableString alloc] initWithCString:errmess encoding:NSUTF8StringEncoding] forKey:@"Errmess"];
                
                [arrColas addObject:currentDic];
                
            }
            sqlite3_finalize(recordset);
        }
        [self cerrarBD];
        
    }
    
    
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
        [self Alerta:@"Mensaje" Mensaje:@"Error al leer la DB intente de nuevo." TextoBtnCancel:@"Ok"];
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
    }else{
        cell.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
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
