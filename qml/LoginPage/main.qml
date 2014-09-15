import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.1
import mywindow 1.0
import utility 1.0
import "../"

MyWindow{
    id:main
    windowIcon: "qrc:/images/avatar.png"
    width: 450/1366*screen.size.width
    height: 3/4*width
    visible: true//可视的
    noBorder: true//无边框的
    removable: true//可移动的
    fixedSize: true//固定大小的
    dockableWindow: false//可停靠的
    topHint: false//窗口保持在最前端
    noNotifyIcon: false//隐藏任务栏图标
    
    color: "transparent"
    Component.onCompleted: {
        main.x = screen.size.width/2 - main.width/2//让程序居中显示
        main.y = screen.size.height/2 - main.height/2
    }

    Connections{
        target: myqq
        onError:{
            if( message.indexOf("验证码")<0 ){
                login_page.reLogin()//重新登录
                myqq.inputCodeClose()//关闭输入验证码
            }else{
                myqq.updateCode()//刷新验证码
            }
        }
        onLoginStatusChanged:{
            if(myqq.loginStatus == QQ.LoginFinished){
                utility.loadQml("qml/MainPanelPage/main.qml")
                main.close()
            }
        }
    }

    Connections{
        target: systemTray
        onActivated:{
            if( arg == MySystemTrayIcon.Trigger ) {
                utility.consoleLog("点击了托盘")
                if(main.visible) {
                    if( main.visibility!= Window.Windowed){
                        main.show()
                    }
                    main.requestActivate()//让窗体显示出来
                }
            }
        }
        onTriggered: {
            if(arg == "打开主面板"){
                if(main.visible) {
                    if( main.visibility!= Window.Windowed){
                        main.show()
                    }
                    main.requestActivate()//让窗体显示出来
                }
            }
        }
    }
    function openSettingPage() {//进行设置
        var component = Qt.createComponent("SettingPage.qml");
        if (component.status == Component.Ready){
            var sprite = component.createObject(settings_page);
            login_page.enabled=false
            flipable.flipped = false
        }
    }
    function openLoginPage() {//打开登录面板
        login_page.reLogin()//重新登录
        flipable.flipped = true
    }
    
    Flipable {
         id: flipable
         anchors.fill: parent
         property bool flipped: true
    
         front: LoginPage{
             id: login_page
             anchors.right: parent.right
         }
         back: Item{id: settings_page;anchors.fill: parent}
    
         transform: Rotation {
             id: rotation
             origin.x: flipable.width/2
             origin.y: flipable.height/2
             axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
             angle: 0    // the default angle
         }
    
         states: State {
             name: "back"
             PropertyChanges { target: rotation; angle: 180 }
             when: !flipable.flipped
         }
    
         transitions: Transition {
             NumberAnimation { target: rotation; property: "angle"; duration: 200 ;easing.type: Easing.InQuart}
         }
    }
}