object Form1: TForm1
  Left = 365
  Top = 414
  Width = 486
  Height = 236
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Button1: TButton
    Left = 72
    Top = 88
    Width = 75
    Height = 25
    Caption = 'symfromaddr'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 200
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 200
    Top = 16
    Width = 121
    Height = 24
    TabOrder = 2
    Text = 'wdigest.dll'
  end
  object Edit2: TEdit
    Left = 200
    Top = 48
    Width = 121
    Height = 24
    TabOrder = 3
    Text = 'SpAcceptCredentials'
  end
  object Button3: TButton
    Left = 200
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 4
    OnClick = Button3Click
  end
end
