//
//  ConsultaWsController.m
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import "ConsultaWsController.h"
#import "ConsultaViewController.h"
#import "AppDelegate.h"

@interface ConsultaWsController ()
{
    AppDelegate * objGlobal;
}
@end

@implementation ConsultaWsController
@synthesize txt_cliente;
@synthesize txt_cola;

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
    if( ! objGlobal.strCliente) {
        objGlobal.strCliente = [[NSString alloc] init];
    }
    if( ! objGlobal.strCola) {
        objGlobal.strCola = [[NSString alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)consultarWS:(id)sender {
    
    //validacion de captura.
    if ([txt_cliente.text isEqualToString:@""]) {
        txt_cliente.text = @"400";
    }
    if ([txt_cola.text isEqualToString:@""]) {
        txt_cola.text = @"*";
    }

    objGlobal.strCliente = txt_cliente.text;
    NSLog(@"%@", objGlobal.strCliente);
    

    objGlobal.strCola = txt_cola.text;
    NSLog(@"%@", objGlobal.strCola);
    
    ConsultaViewController *consultaView = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsultaViewController"];
    [self.navigationController pushViewController:consultaView animated:YES];
    
}
- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
}
@end
