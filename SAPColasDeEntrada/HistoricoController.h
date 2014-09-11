//
//  HistoricoController.h
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoricoController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *mesAnioPicker;
- (IBAction)consultarHis:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txt_cliente;
@property (strong, nonatomic) IBOutlet UITextField *txt_cola;

@end
