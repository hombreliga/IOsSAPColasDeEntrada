//
//  DetalleController.m
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 04/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import "DetalleController.h"
#import "AppDelegate.h"

@interface DetalleController ()
{
    AppDelegate * objGlobal;
}
@end

@implementation DetalleController
@synthesize lblID;

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
    
    [self.lblID setText:objGlobal.strID];
    [self.lblDestino setText:objGlobal.strDestino];
    [self.lblNumero setText:objGlobal.strNumero];
    [self.lblEstatus setText:objGlobal.strEstatus];
    [self.lblFecha setText:objGlobal.strFecha];
    [self.lblHora setText:objGlobal.strHora];
    
    [self.txtError setText:objGlobal.strTxtError];
    [self.txtID setText:objGlobal.strTxtID];
    
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

@end
