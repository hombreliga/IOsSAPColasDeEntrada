//
//  ConsultaWsController.h
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsultaWsController : UIViewController 
- (IBAction)consultarWS:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txt_cliente;
@property (strong, nonatomic) IBOutlet UITextField *txt_cola;
- (IBAction)textFieldReturn:(id)sender;
@end
