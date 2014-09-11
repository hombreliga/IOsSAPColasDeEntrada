//
//  DetalleController.h
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 04/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetalleController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblID;
@property (weak, nonatomic) IBOutlet UILabel *lblDestino;
@property (weak, nonatomic) IBOutlet UILabel *lblNumero;
@property (weak, nonatomic) IBOutlet UILabel *lblEstatus;
@property (weak, nonatomic) IBOutlet UILabel *lblFecha;
@property (weak, nonatomic) IBOutlet UILabel *lblHora;
@property (weak, nonatomic) IBOutlet UITextView *txtError;
@property (weak, nonatomic) IBOutlet UITextView *txtID;

@end
