import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import FluentUI
import "qrc:///example/qml/global"
import "qrc:///example/qml/component"

FluScrollablePage{

    title:"Settings"

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 128
        paddings: 10

        ColumnLayout{
            spacing: 5
            anchors{
                top: parent.top
                left: parent.left
            }
            FluText{
                text:lang.dark_mode
                font: FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }
            Repeater{
                model: [{title:"System",mode:FluDarkMode.System},{title:"Light",mode:FluDarkMode.Light},{title:"Dark",mode:FluDarkMode.Dark}]
                delegate:  FluRadioButton{
                    checked : FluTheme.darkMode === modelData.mode
                    text:modelData.title
                    clickListener:function(){
                        FluTheme.darkMode = modelData.mode
                    }
                }
            }
        }
    }

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 160
        paddings: 10

        ColumnLayout{
            spacing: 5
            anchors{
                top: parent.top
                left: parent.left
            }
            FluText{
                text:lang.navigation_view_display_mode
                font: FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }
            Repeater{
                model: [{title:"Open",mode:FluNavigationView.Open},{title:"Compact",mode:FluNavigationView.Compact},{title:"Minimal",mode:FluNavigationView.Minimal},{title:"Auto",mode:FluNavigationView.Auto}]
                delegate: FluRadioButton{
                    checked : MainEvent.displayMode===modelData.mode
                    text:modelData.title
                    clickListener:function(){
                        MainEvent.displayMode = modelData.mode
                    }
                }
            }
        }
    }

    FluArea{
        Layout.fillWidth: true
        Layout.topMargin: 20
        height: 80
        paddings: 10

        ColumnLayout{
            spacing: 10
            anchors{
                top: parent.top
                left: parent.left
            }

            FluText{
                text:lang.locale
                font: FluTextStyle.BodyStrong
                Layout.bottomMargin: 4
            }

            Flow{
                spacing: 5
                Repeater{
                    model: ["Zh","En"]
                    delegate: FluRadioButton{
                        checked: appInfo.lang.objectName === modelData
                        text:modelData
                        clickListener:function(){
                            appInfo.changeLang(modelData)
                        }
                    }
                }
            }
        }
    }

}
