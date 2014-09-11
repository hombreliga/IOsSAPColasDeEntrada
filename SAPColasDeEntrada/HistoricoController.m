//
//  HistoricoController.m
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import "HistoricoController.h"
#import "AppDelegate.h"
#import "HistoricoViewController.h"

@interface HistoricoController ()
{
    NSMutableArray *mesesArray;
    NSMutableArray *anioArray;
    
    AppDelegate *objGlobal;
    
}
@end

@implementation HistoricoController
@synthesize mesAnioPicker,txt_cliente,txt_cola;

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
    [self prepararPicker];
    if( ! objGlobal.strCola) {
        objGlobal.strCola = [[NSString alloc] init];
    }
    if( ! objGlobal.strMes) {
        objGlobal.strMes = [[NSString alloc] init];
    }
        objGlobal.strMes = @"";
    
    if( ! objGlobal.strAnio) {
        objGlobal.strAnio = [[NSString alloc] init];
    }
        objGlobal.strAnio = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepararPicker{
    mesesArray = [[NSMutableArray alloc] initWithObjects:@"Enero",@"Febrero",@"Marzo",@"Abril",@"Mayo",@"Junio",@"Julio",@"Agosto",@"Septiembre",@"Octubre",@"Noviembre",@"Diciembre", nil];
    
    NSDateFormatter *formato = [[NSDateFormatter alloc] init];
    [formato setDateFormat:@"yyyy"];
    NSString *anioString = [formato stringFromDate:[NSDate date]];
    
    anioArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<3; i++)
    {
        [anioArray addObject:[NSString stringWithFormat:@"%d",[anioString intValue] - i]];
        
    }
    /*mesAnioPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
    mesAnioPicker.delegate = self;
    mesAnioPicker.showsSelectionIndicator = YES;
    [mesAnioPicker selectRow:0 inComponent:0 animated:YES];
    [self.view addSubview:mesAnioPicker];*/
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rowsInComponent;
    if (component==0) {
        rowsInComponent=[mesesArray count];
    }else
    {
        rowsInComponent=[anioArray count];
    }
    return rowsInComponent;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * nameInRow;
    if (component==0) {
        nameInRow=[mesesArray objectAtIndex:row];
    }else
    {
        nameInRow=[anioArray objectAtIndex:row];
    }
    
    return nameInRow;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth;
    
    if (component==0) {
        componentWidth = 130;
    }else
    {
        componentWidth = 70;
    }

    return componentWidth;
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

- (IBAction)consultarHis:(id)sender {
    //validacion de captura.
    if ([txt_cola.text isEqualToString:@""]) {
        txt_cola.text = @"*";
    }
    if ([objGlobal.strMes isEqualToString:@""]) {
        objGlobal.strMes = [mesesArray objectAtIndex:0];
    }
    if ([objGlobal.strAnio isEqualToString:@""]) {
        objGlobal.strAnio = [anioArray objectAtIndex:0];
    }
    
    objGlobal.strCola = txt_cola.text;

    
    HistoricoViewController *historicoView = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoricoViewController"];
    [self.navigationController pushViewController:historicoView animated:YES];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        objGlobal.strMes = [mesesArray objectAtIndex:row];
    }
    if (component == 1) {
        objGlobal.strAnio = [anioArray objectAtIndex:row];
    }
}
@end
