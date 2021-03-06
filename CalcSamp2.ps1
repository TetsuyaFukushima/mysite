[void] [Reflection.Assembly]::Load('UIAutomationClient, ' + 
    'Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
[void] [Reflection.Assembly]::Load('UIAutomationTypes, ' + 
    'Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
function global:GetChildElement([Windows.Automation.AutomationElement]$objElement,[string]$property,[string]$name_value="")
{
    Switch ($property)
    {
        'Name' {
            $condition = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty,$name_value)
            }
        'Class' {
            $condition = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ClassNameProperty,$name_value)
            }
        'AutomationId'{
            $condition = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::AutomationIdProperty,$name_value)
            }                
    }
    $secondWin = $objElement.FindFirst([Windows.Automation.TreeScope]::Children, $condition)
    return $secondWin
}
function global:ItemClick([Windows.Automation.AutomationElement]$objElement)
{
    $ip=$objElement.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $ip.invoke()
    return $ip
}
function global:MenuSelect([Windows.Automation.AutomationElement]$objMenu,[string]$strMenu)
{
    $arry = $strMenu -split ","
    #MessageBox $arry.Length;
    for ($i = 0;$i -lt $arry.Length-1;$i++)
    {
        #MessageBox $arry[$i]
        $objChild = GetChildElement $objMenu 'Name' $arry[$i]
        $ep = $objChild.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
        $ep.expand()
        start-sleep -s 1
        $objMenu = GetChildElement $objChild 'Name' $arry[$i]
    }
    #MessageBox $arry[-1];
    $objItm = GetChildElement $objMenu 'Name' $arry[-1]
    $ip = $objItm.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $ip.invoke()    
    return $ip
}
function global:SetText([Windows.Automation.AutomationElement]$objTxt,[string]$strValue="")
{
    $vp = $objTxt.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)
    $vp.SetValue($strValue)
    return $vp
}
function global:MessageBox([string]$p_value = "")
{
    $a = new-object -comobject wscript.shell
    $b = $a.popup($p_value,0,"sample",0)
    #[Void][Windows.Forms.MessageBox]::Show($p_value,"WindowsPowerShell");
}

#CSharpを使用してRootElementを取得する
#PowerShellは常にMTA(Multi Thread Apartment)モードであり、
#UIAutomationはSTA(Single Thread Apartment)モードで動作するので
#直接は使用できないらしい。(rootElement以外は使用できる)
$source = @"
using System;
using System.Windows.Automation;
namespace UIAutTools
{    
    public class Element
    {        
        public static AutomationElement RootElement
        {            
            get
            {                
                return AutomationElement.RootElement;
            }        
        }    
    }
}
"@
#電卓を起動
start-process 'calc'
#1秒待つ
start-sleep -s 1

MessageBox "'123456789x9='を実施";


Add-Type -TypeDefinition $source -ReferencedAssemblies("UIAutomationClient", "UIAutomationTypes")
$root = [UIAutTools.Element]::RootElement

#[電卓]アプリケーション取得
$appCalc = GetChildElement $root 'Name' '電卓'

#[電卓]第2ウィンドウ取得
$secondWin = GetChildElement $appCalc 'Class' 'CalcFrame'

#[1]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '1'
$Ret = ItemClick($Btn1)

#[2]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '2'
$Ret = ItemClick($Btn1)

#[3]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '3'
$Ret = ItemClick($Btn1)

#[4]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '4'
$Ret = ItemClick($Btn1)

#[5]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '5'
$Ret = ItemClick($Btn1)

#[6]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '6'
$Ret = ItemClick($Btn1)

#[7]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '7'
$Ret = ItemClick($Btn1)

#[8]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '8'
$Ret = ItemClick($Btn1)

#[9]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '9'
$Ret = ItemClick($Btn1)

#[0]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '0'
$Ret = ItemClick($Btn1)

start-sleep -s 1

#[x]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '乗算'
$Ret = ItemClick($Btn1)

#[9]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '9'
$Ret = ItemClick($Btn1)

start-sleep -s 1

#[=]ボタン取得&押下
$Btn1 = GetChildElement $secondWin 'Name' '等号'
$Ret = ItemClick($Btn1)

start-sleep -s 3
MessageBox "プログラマ電卓に変更";
#メニューバー取得
$Menu = GetChildElement $appCalc 'AutomationId' 'MenuBar'
$Ret = MenuSelect $Menu '表示(V),プログラマ(P)'

start-sleep -s 1
MessageBox "住宅ローン";
$Ret = MenuSelect $Menu '表示(V),ワークシート(W),住宅ローン(M)'
start-sleep -s 1

$comboLoan=GetChildElement $secondWin 'Class' 'ComboBox'
$ep = $comboLoan.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
$ep.expand()

$comboLBox=GetChildElement $comboLoan 'Name' '出力フィールド'
$comboHead=GetChildElement $comboLBox 'Name' '頭金'

$cip = $comboHead.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
$cip.select()

$txtBuy=GetChildElement $secondWin 'AutomationId' '245'
$Ret=SetText $txtBuy '100'

$txtTime=GetChildElement $secondWin 'AutomationId' '246'
$Ret=SetText $txtTime '20'

$txtRate=GetChildElement $secondWin 'AutomationId' '247'
$Ret=SetText $txtRate '1'

$txtPay=GetChildElement $secondWin 'AutomationId' '248'
$Ret=SetText $txtPay '10'

$BtnCalc=GetChildElement $secondWin 'Name' '計算'
$Ret=ItemClick($BtnCalc)

start-sleep -s 1
MessageBox "普通の電卓に変更";
$Ret = MenuSelect $Menu '表示(V),普通の電卓(T)'

start-sleep -s 1
$Ret = MenuSelect $Menu '表示(V),基本(B)'

start-sleep -s 1
MessageBox "電卓の終了";

#タイトルバー取得
$appTitle = GetChildElement $appCalc 'AutomationId' 'TitleBar'

#タイトルバー右上のxボタン取得&押下
$BtnClose = GetChildElement $appTitle 'Name' '閉じる'
$Ret=ItemClick($BtnClose)
