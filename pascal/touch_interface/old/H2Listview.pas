Unit H2Listview;

Interface

Uses
  Messages,Windows, Classes,Controls, ExtCtrls, SysUtils,GR32_Image,GR32,gr32_layers,Graphics
  ,ComCtrls,XMLDoc,XMLIntf;

Type

  TH2ListView = Class(TControl)
  Private
    fx,
    fy,
    fwidth,
    fheight:Integer;
    fvisible:Boolean;
    ffont:tfont;
    fbitmap:tbitmaplayer;
    fdrawmode:tdrawmode;
    falpha:Cardinal;
    ftree:ttreeview;
    Procedure SetFont(font:tfont);
    Procedure Setvisible(value:Boolean);
    Procedure Tree2XML(tree: TTreeView;filename:String);
    Procedure XML2Tree(tree   : TTreeView;XMLDoc : TXMLDocument);
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Property Font:tfont Read ffont Write setfont;
    Property Alpha:Cardinal Read falpha Write falpha;
    Property DrawMode:tdrawmode Read fdrawmode Write fdrawmode;
    Property X:Integer Read fx Write fx;
    Property Y:Integer Read fy Write fy;
    Property Bitmap:tbitmaplayer Read fbitmap Write fbitmap;
    Property Visible:Boolean Read fvisible Write setvisible;
    Property OnMouseDown;
  End;

Implementation

{ TH2ListView }

Constructor TH2ListView.Create(AOwner: TComponent);
Var
  L: TFloatRect;
  alayer:tbitmaplayer;
Begin
  Inherited Create(AOwner);
  fbitmap:=TBitmapLayer.Create((aowner As timage32).Layers);
  ffont:=tfont.Create;
  fdrawmode:=dmblend;
  falpha:=255;
  fvisible:=True;
  fx:=0;
  fy:=0;
  fwidth:=100;
  fheight:=100;
  fbitmap.Bitmap.Width:=fwidth;
  fbitmap.Bitmap.Height:=fheight;
  l.Left:=fx;
  l.Top:=fy;
  l.Right:=fx+fwidth;
  l.Bottom:=fy+fheight;
  fbitmap.Location:=l;
  fbitmap.Tag:=0;
  fbitmap.Bitmap.DrawMode:=fdrawmode;
  fbitmap.Bitmap.MasterAlpha:=falpha;
  fvisible:=True;

End;

Destructor TH2ListView.Destroy;
Begin
//here
  ffont.Free;
  fbitmap.Free;
  Inherited Destroy;
End;

Procedure TH2ListView.SetFont(font: tfont);
Begin
  ffont.Assign(font);
End;

Procedure TH2ListView.Setvisible(value: Boolean);
Begin
  fbitmap.Visible:=value;
End;

Procedure TH2ListView.Tree2XML(tree: TTreeView;filename:String);
Var
  tn : TTreeNode;
  XMLDoc : TXMLDocument;
  iNode : IXMLNode;

  Procedure ProcessTreeItem(
    tn    : TTreeNode;
    iNode : IXMLNode);
  Var
    cNode : IXMLNode;
  Begin
    If (tn = Nil) Then Exit;
    cNode := iNode.AddChild('item');
    cNode.Attributes['text'] := tn.Text;
    cNode.Attributes['imageIndex'] := tn.ImageIndex;
    cNode.Attributes['stateIndex'] := tn.StateIndex;

    //child nodes
    tn := tn.getFirstChild;
    While tn <> Nil Do
      Begin
      ProcessTreeItem(tn, cNode);
      tn := tn.getNextSibling;
      End;
  End; (*ProcessTreeItem*)
Begin
  XMLDoc := TXMLDocument.Create(Nil);
  XMLDoc.Active := True;
  iNode  := XMLDoc.AddChild('tree2xml');
  iNode.Attributes['app'] := 'Hydrogen';

  tn := tree.TopItem;
  While tn <> Nil Do
    Begin
    ProcessTreeItem (tn, iNode);

    tn := tn.getNextSibling;
    End;

  XMLDoc.SaveToFile(filename);

  XMLDoc := Nil;
End; (* Tree2XML *)

Procedure TH2ListView.XML2Tree(tree   : TTreeView;XMLDoc : TXMLDocument);
Var
  iNode : IXMLNode;

  Procedure ProcessNode(
    Node : IXMLNode;
    tn   : TTreeNode);
  Var
    cNode : IXMLNode;
  Begin
    If Node = Nil Then Exit;
    With Node Do
      Begin
      tn := tree.Items.AddChild(tn, Attributes['text']);
      tn.ImageIndex := Integer(Attributes['imageIndex']);
      tn.StateIndex := Integer(Attributes['stateIndex']);
      End;


    cNode := Node.ChildNodes.First;
    While cNode <> Nil Do
      Begin
      ProcessNode(cNode, tn);
      cNode := cNode.NextSibling;
      End;
  End; (*ProcessNode*)
Begin
  tree.Items.Clear;
  XMLDoc.FileName := ChangeFileExt(ParamStr(0),'.XML');
  XMLDoc.Active := True;

  iNode := XMLDoc.DocumentElement.ChildNodes.First;

  While iNode <> Nil Do
    Begin
    ProcessNode(iNode,Nil);
    iNode := iNode.NextSibling;
    End;

  XMLDoc.Active := False;
End;

End.
