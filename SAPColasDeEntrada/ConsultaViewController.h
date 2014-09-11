//
//  ConsultaViewController.h
//  SAPColasDeEntrada
//
//  Created by Cesar Yañez on 02/09/14.
//  Copyright (c) 2014 Omnilife. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsultaViewController : UIViewController <NSXMLParserDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tabla;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicador;

@end
