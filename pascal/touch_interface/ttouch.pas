{ This file was automatically created by Lazarus. do not edit!
  This source is only used to compile and install the package.
 }

unit ttouch; 

interface

uses
    tswitchbutton, timagebutton, tgraphiclabel, TThrobber, ButtonSlider, 
  VertButtonSlider, HorizProgressBar, GraphicPanel, GraphicMemo, 
  MultiStateButton, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('tswitchbutton', @tswitchbutton.Register); 
  RegisterUnit('timagebutton', @timagebutton.Register); 
  RegisterUnit('tgraphiclabel', @tgraphiclabel.Register); 
  RegisterUnit('TThrobber', @TThrobber.Register); 
  RegisterUnit('ButtonSlider', @ButtonSlider.Register); 
  RegisterUnit('VertButtonSlider', @VertButtonSlider.Register); 
  RegisterUnit('HorizProgressBar', @HorizProgressBar.Register); 
  RegisterUnit('GraphicPanel', @GraphicPanel.Register); 
  RegisterUnit('GraphicMemo', @GraphicMemo.Register); 
  RegisterUnit('MultiStateButton', @MultiStateButton.Register); 
end; 

initialization
  RegisterPackage('ttouch', @Register); 
end.
