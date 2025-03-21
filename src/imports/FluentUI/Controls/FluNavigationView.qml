import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import FluentUI

Item {
    enum DisplayMode {
        Open = 0,
        Compact = 1,
        Minimal = 2,
        Auto = 3
    }
    enum PageModeFlag{
        Standard = 0,
        SingleTask = 1,
        SingleTop = 2,
        SingleInstance = 3
    }
    property url logo
    property string title: ""
    property FluObject items
    property FluObject footerItems
    property bool dontPageAnimation: false
    property int displayMode: FluNavigationView.Auto
    property Component autoSuggestBox
    property Component actionItem
    property int topPadding: 0
    signal logoClicked
    id:control
    QtObject{
        id:d
        property var stackItems: []
        property int displayMode: FluNavigationView.Open
        property bool enableNavigationPanel: false
        property bool isCompact: d.displayMode === FluNavigationView.Compact
        property bool isMinimal: d.displayMode === FluNavigationView.Minimal
        property bool isCompactAndPanel: d.displayMode === FluNavigationView.Compact && d.enableNavigationPanel
        property bool isCompactAndNotPanel:d.displayMode === FluNavigationView.Compact && !d.enableNavigationPanel
        property bool isMinimalAndPanel: d.displayMode === FluNavigationView.Minimal && d.enableNavigationPanel
        onIsCompactAndNotPanelChanged: {
            collapseAll()
        }
        function handleItems(){
            var idx = 0
            var data = []
            if(items){
                for(var i=0;i<items.children.length;i++){
                    var item = items.children[i]
                    item.idx = idx
                    data.push(item)
                    idx++
                    if(item instanceof FluPaneItemExpander){
                        for(var j=0;j<item.children.length;j++){
                            var itemChild = item.children[j]
                            itemChild.parent = item
                            itemChild.idx = idx
                            data.push(itemChild)
                            idx++
                        }
                    }
                }
                if(footerItems){
                    var comEmpty = Qt.createComponent("FluPaneItemEmpty.qml");
                    for(var k=0;k<footerItems.children.length;k++){
                        var itemFooter = footerItems.children[k]
                        if (comEmpty.status === Component.Ready) {
                            var objEmpty = comEmpty.createObject(items,{idx:idx});
                            itemFooter.idx = idx;
                            data.push(objEmpty)
                            idx++
                        }
                    }
                }
            }
            return data
        }
    }
    Component.onCompleted: {
        d.displayMode = Qt.binding(function(){
            if(control.displayMode !==FluNavigationView.Auto){
                return control.displayMode
            }
            if(control.width<=700){
                return FluNavigationView.Minimal
            }else if(control.width<=900){
                return FluNavigationView.Compact
            }else{
                return FluNavigationView.Open
            }
        })
    }
    Connections{
        target: d
        function onDisplayModeChanged(){
            if(d.displayMode === FluNavigationView.Compact){
                collapseAll()
            }
            if(d.displayMode === FluNavigationView.Minimal){
                d.enableNavigationPanel = false
            }
        }
    }
    Component{
        id:com_panel_item_empty
        Item{
            visible: false
        }
    }
    Component{
        id:com_panel_item_separatorr
        FluDivider{
            width: layout_list.width
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 1 : 0
                }
                return 1
            }
            Behavior on height {
                NumberAnimation{
                    duration: 83
                }
            }
        }
    }
    Component{
        id:com_panel_item_header
        Item{
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 30 : 0
                }
                return 30
            }
            Behavior on height {
                NumberAnimation{
                    duration: 83
                }
            }
            width: layout_list.width
            FluText{
                text:model.title
                font: FluTextStyle.BodyStrong
                anchors{
                    bottom: parent.bottom
                    left:parent.left
                    leftMargin: 10
                }
            }
        }
    }
    Component{
        id:com_panel_item_expander
        Item{
            height: 38
            width: layout_list.width
            FluControl{
                id:item_control
                anchors{
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                onClicked: {
                    if(d.isCompactAndNotPanel){
                        control_popup.showPopup(Qt.point(50,mapToItem(control,0,0).y),model.children)
                        return
                    }
                    model.isExpand = !model.isExpand
                }
                Rectangle{
                    color:Qt.rgba(255/255,77/255,79/255,1)
                    width: 10
                    height: 10
                    radius: 5
                    border.width: 1
                    border.color: Qt.rgba(1,1,1,1)
                    anchors{
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 3
                        verticalCenterOffset: -8
                    }
                    visible: {
                        if(!model.isExpand){

                            for(var i=0;i<model.children.length;i++){
                                var item = model.children[i]
                                if(item.infoBadge && item.count !==0){
                                    return true
                                }
                            }
                        }
                        return false
                    }
                }

                Rectangle{
                    radius: 4
                    anchors.fill: parent
                    Rectangle{
                        width: 3
                        height: 18
                        radius: 1.5
                        color: FluTheme.primaryColor.dark
                        visible: {
                            for(var i=0;i<model.children.length;i++){
                                var item = model.children[i]
                                if(item.idx === nav_list.currentIndex && !model.isExpand){
                                    return true
                                }
                            }
                            return false
                        }
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    FluIcon{
                        id:item_icon_expand
                        rotation: model.isExpand?0:180
                        iconSource:FluentIcons.ChevronUp
                        iconSize: 15
                        anchors{
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 12
                        }
                        visible: {
                            if(d.isCompactAndNotPanel){
                                return false
                            }
                            return true
                        }
                        Behavior on rotation {
                            NumberAnimation{
                                duration: 83
                            }
                        }
                    }
                    color: {
                        if(FluTheme.dark){
                            if((nav_list.currentIndex === idx)&&type===0){
                                return Qt.rgba(1,1,1,0.06)
                            }
                            if(item_control.hovered){
                                return Qt.rgba(1,1,1,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }else{
                            if(nav_list.currentIndex === idx&&type===0){
                                return Qt.rgba(0,0,0,0.06)
                            }
                            if(item_control.hovered){
                                return Qt.rgba(0,0,0,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }
                    }
                    Component{
                        id:com_icon
                        FluIcon{
                            iconSource: {
                                if(model.icon){
                                    return model.icon
                                }
                                return 0
                            }
                            iconSize: 15
                        }
                    }
                    Item{
                        id:item_icon
                        width: 30
                        height: 30
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left:parent.left
                            leftMargin: 3
                        }
                        Loader{
                            anchors.centerIn: parent
                            sourceComponent: {
                                if(model.cusIcon){
                                    return model.cusIcon
                                }
                                return com_icon
                            }
                        }
                    }
                    FluText{
                        id:item_title
                        text:model.title
                        visible: {
                            if(d.isCompactAndNotPanel){
                                return false
                            }
                            return true
                        }
                        elide: Text.ElideRight
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left:item_icon.right
                            right: item_icon_expand.left
                        }
                        color:{
                            if(item_control.pressed){
                                return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                            }
                            return FluTheme.dark ? FluColors.White : FluColors.Grey220
                        }
                    }
                }
            }
        }
    }
    Component{
        id:com_panel_item
        Item{
            Behavior on height {
                NumberAnimation{
                    duration: 83
                }
            }
            clip: true
            height: {
                if(model.parent){
                    return model.parent.isExpand ? 38 : 0
                }
                return 38
            }
            visible: {
                if(model.parent){
                    return model.parent.isExpand ? true : false
                }
                return true
            }
            width: layout_list.width
            FluControl{
                id:item_control
                anchors{
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: 2
                    bottomMargin: 2
                    leftMargin: 6
                    rightMargin: 6
                }
                onClicked: {
                    if(type === 0){
                        if(model.tapFunc){
                            model.tapFunc()
                        }else{
                            nav_list.currentIndex = idx
                            layout_footer.currentIndex = -1
                            model.tap()
                            if(d.isMinimal || d.isCompact){
                                d.enableNavigationPanel = false
                            }
                        }
                    }else{
                        if(model.tapFunc){
                            model.tapFunc()
                        }else{
                            nav_list.currentIndex = nav_list.count-layout_footer.count+idx
                            layout_footer.currentIndex = idx
                            model.tap()
                            if(d.isMinimal || d.isCompact){
                                d.enableNavigationPanel = false
                            }
                        }
                    }
                }
                Rectangle{
                    radius: 4
                    anchors.fill: parent
                    color: {
                        if(FluTheme.dark){
                            if(type===0){
                                if(nav_list.currentIndex === idx){
                                    return Qt.rgba(1,1,1,0.06)
                                }
                            }else{
                                if(nav_list.currentIndex === (nav_list.count-layout_footer.count+idx)){
                                    return Qt.rgba(1,1,1,0.06)
                                }
                            }
                            if(item_control.hovered){
                                return Qt.rgba(1,1,1,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }else{
                            if(type===0){
                                if(nav_list.currentIndex === idx){
                                    return Qt.rgba(0,0,0,0.06)
                                }
                            }else{
                                if(nav_list.currentIndex === (nav_list.count-layout_footer.count+idx)){
                                    return Qt.rgba(0,0,0,0.06)
                                }
                            }
                            if(item_control.hovered){
                                return Qt.rgba(0,0,0,0.03)
                            }
                            return Qt.rgba(0,0,0,0)
                        }
                    }
                    Component{
                        id:com_icon
                        FluIcon{
                            iconSource: {
                                if(model.icon){
                                    return model.icon
                                }
                                return 0
                            }
                            iconSize: 15
                        }
                    }
                    Item{
                        id:item_icon
                        width: 30
                        height: 30
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left:parent.left
                            leftMargin: 3
                        }
                        Loader{
                            anchors.centerIn: parent
                            sourceComponent: {
                                if(model.cusIcon){
                                    return model.cusIcon
                                }
                                return com_icon
                            }
                        }
                    }
                    FluText{
                        id:item_title
                        text:model.title
                        visible: {
                            if(d.isCompactAndNotPanel){
                                return false
                            }
                            return true
                        }
                        elide: Text.ElideRight
                        color:{
                            if(item_control.pressed){
                                return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120
                            }
                            return FluTheme.dark ? FluColors.White : FluColors.Grey220
                        }
                        anchors{
                            verticalCenter: parent.verticalCenter
                            left:item_icon.right
                            right: item_dot_loader.left
                        }
                    }
                    Loader{
                        id:item_dot_loader
                        property bool isDot: (item_dot_loader.item&&item_dot_loader.item.isDot)
                        anchors{
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: isDot ? 3 : 10
                            verticalCenterOffset: isDot ? -8 : 0
                        }
                        sourceComponent: {
                            if(model.infoBadge){
                                return model.infoBadge
                            }
                            return undefined
                        }
                        Connections{
                            target: d
                            function onIsCompactAndNotPanelChanged(){
                                if(item_dot_loader.item){
                                    item_dot_loader.item.isDot = d.isCompactAndNotPanel
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Item {
        id:nav_app_bar
        width: parent.width
        height: 40
        anchors{
            top: parent.top
            topMargin: control.topPadding
        }
        z:999
        RowLayout{
            height:parent.height
            spacing: 0
            FluIconButton{
                id:btn_back
                iconSource: FluentIcons.ChromeBack
                Layout.leftMargin: 5
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
                disabled:  nav_swipe.depth <= 1
                iconSize: 13
                onClicked: {
                    FluTools.deleteItem(nav_swipe.pop())
                    d.stackItems.pop()
                    var item = d.stackItems[d.stackItems.length-1]
                    if(item.idx<(nav_list.count - layout_footer.count)){
                        layout_footer.currentIndex = -1
                    }else{
                        layout_footer.currentIndex = item.idx-(nav_list.count-layout_footer.count)
                    }
                    nav_list.currentIndex = item.idx
                    if(nav_swipe.currentItem.pageMode === FluNavigationView.SingleInstance){
                        var url = nav_swipe.currentItem.url
                        var pageIndex = -1
                        for(var i=0;i<nav_swipe2.children.length;i++){
                            var obj =  nav_swipe2.children[i]
                            if(obj.url === url){
                                pageIndex = i
                                break
                            }
                        }
                        if(pageIndex !== -1){
                            nav_swipe2.currentIndex = pageIndex
                        }
                    }
                }
            }
            FluIconButton{
                id:btn_nav
                iconSource: FluentIcons.GlobalNavButton
                iconSize: 15
                Layout.preferredWidth: d.isMinimal ? 30 : 0
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
                clip: true
                onClicked: {
                    d.enableNavigationPanel = !d.enableNavigationPanel
                }
                visible: opacity
                opacity: d.isMinimal
                Behavior on opacity{
                    NumberAnimation{
                        duration: 83
                    }
                }
                Behavior on Layout.preferredWidth {
                    NumberAnimation{
                        duration: 167
                        easing.type: Easing.InCubic
                    }
                }
            }
            Image{
                id:image_logo
                Layout.preferredHeight: 20
                Layout.preferredWidth: 20
                source: control.logo
                Layout.leftMargin: {
                    if(btn_nav.visible){
                        return 12
                    }
                    return 5
                }
                sourceSize: Qt.size(40,40)
                Layout.alignment: Qt.AlignVCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        logoClicked()
                    }
                }
            }
            FluText{
                Layout.alignment: Qt.AlignVCenter
                text:control.title
                Layout.leftMargin: 12
                font: FluTextStyle.Body
            }
        }
        Item{
            anchors.right: parent.right
            height: parent.height
            width: {
                if(loader_action.item){
                    return loader_action.item.width
                }
                return 0
            }
            Loader{
                id:loader_action
                anchors.centerIn: parent
                sourceComponent: actionItem
            }
        }
    }
    Item{
        anchors{
            left: parent.left
            top: nav_app_bar.bottom
            right: parent.right
            bottom: parent.bottom
            leftMargin: {
                if(d.isMinimal){
                    return 0
                }
                if(d.isCompact){
                    return 50
                }
                return 300
            }
        }
        Behavior on anchors.leftMargin {
            NumberAnimation{
                duration: 167
                easing.type: Easing.InCubic
            }
        }
        StackView{
            id:nav_swipe
            anchors.fill: parent
            clip: true
            visible: !nav_swipe2.visible
            popEnter : Transition{}
            popExit : Transition {}
            pushEnter: Transition {}
            pushExit : Transition{}
            replaceEnter : Transition{}
            replaceExit : Transition{}
        }
        StackLayout{
            id:nav_swipe2
            anchors.fill: nav_swipe
            clip: true
            visible: nav_swipe.currentItem.pageMode === FluNavigationView.SingleInstance
        }
    }
    MouseArea{
        anchors.fill: parent
        visible: d.isMinimalAndPanel||d.isCompactAndPanel
        onWheel: {
        }
        onClicked: {
            d.enableNavigationPanel = false
        }
    }
    Rectangle{
        id:layout_list
        width: {
            if(d.isCompactAndNotPanel){
                return 50
            }
            return 300
        }
        anchors{
            top: parent.top
            bottom: parent.bottom
        }
        border.color: FluTheme.dark ? Qt.rgba(45/255,45/255,45/255,1) : Qt.rgba(226/255,230/255,234/255,1)
        border.width:  d.isMinimal || d.isCompactAndPanel ? 1 : 0
        color: {
            if(d.isMinimal){
                return FluTheme.dark ? Qt.rgba(61/255,61/255,61/255,1) : Qt.rgba(243/255,243/255,243/255,1)
            }
            return "transparent"
        }
        x: visible ? 0 : -width
        Behavior on width {
            NumberAnimation{
                duration: 167
                easing.type: Easing.InCubic
            }
        }
        Behavior on x {
            NumberAnimation{
                duration: 167
                easing.type: Easing.InCubic
            }
        }
        visible: {
            if(d.displayMode !== FluNavigationView.Minimal)
                return true
            return d.isMinimalAndPanel  ? true : false
        }
        FluAcrylic {
            sourceItem:nav_swipe
            anchors.fill: layout_list
            color: {
                if(d.isMinimalAndPanel || d.isCompactAndPanel){
                    return FluTheme.dark ? Qt.rgba(61/255,61/255,61/255,1) : Qt.rgba(243/255,243/255,243/255,1)
                }
                return "transparent"
            }
            visible: d.isMinimalAndPanel || d.isCompactAndPanel
            rectX: d.isCompactAndPanel ? (layout_list.x - 50) : layout_list.x
            rectY: layout_list.y - 60
            acrylicOpacity:0.9
        }
        Item{
            id:layout_header
            width: layout_list.width
            clip: true
            y:nav_app_bar.height+control.topPadding
            height: autoSuggestBox ? 38 : 0
            Loader{
                id:loader_auto_suggest_box
                anchors.centerIn: parent
                sourceComponent: autoSuggestBox
                visible: {
                    if(d.isCompactAndNotPanel){
                        return false
                    }
                    return true
                }
            }
            FluIconButton{
                visible:d.isCompactAndNotPanel
                hoverColor: FluTheme.dark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.03)
                pressedColor: FluTheme.dark ? Qt.rgba(1,1,1,0.03) : Qt.rgba(0,0,0,0.03)
                normalColor: FluTheme.dark ? Qt.rgba(0,0,0,0) : Qt.rgba(0,0,0,0)
                width:38
                height:34
                x:6
                y:2
                iconSize: 15
                iconSource: {
                    if(loader_auto_suggest_box.item){
                        return loader_auto_suggest_box.item.autoSuggestBoxReplacement
                    }
                    return 0
                }
                onClicked: {
                    d.enableNavigationPanel = !d.enableNavigationPanel
                }
            }
        }
        ListView{
            id:nav_list
            clip: true
            ScrollBar.vertical: FluScrollBar {}
            model:d.handleItems()
            highlightMoveDuration: 167
            highlight: Item{
                clip: true
                Rectangle{
                    height: 18
                    radius: 1.5
                    color: FluTheme.primaryColor.dark
                    width: 3
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 6
                    }
                }
            }
            currentIndex: -1
            anchors{
                top: layout_header.bottom
                topMargin: 6
                left: parent.left
                right: parent.right
                bottom: layout_footer.top
            }
            delegate: Loader{
                property var model: modelData
                property var idx: index
                property int type: 0
                sourceComponent: {
                    if(modelData instanceof FluPaneItem){
                        return com_panel_item
                    }
                    if(modelData instanceof FluPaneItemHeader){
                        return com_panel_item_header
                    }
                    if(modelData instanceof FluPaneItemSeparator){
                        return com_panel_item_separatorr
                    }
                    if(modelData instanceof FluPaneItemExpander){
                        return com_panel_item_expander
                    }
                    if(modelData instanceof FluPaneItemEmpty){
                        return com_panel_item_empty
                    }
                }
            }
        }
        ListView{
            id:layout_footer
            clip: true
            width: layout_list.width
            height: childrenRect.height
            anchors.bottom: parent.bottom
            interactive: false
            currentIndex: -1
            model: {
                if(footerItems){
                    return footerItems.children
                }
            }
            highlightMoveDuration: 150
            highlight: Item{
                clip: true
                Rectangle{
                    height: 18
                    radius: 1.5
                    color: FluTheme.primaryColor.dark
                    width: 3
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 6
                    }
                }
            }
            delegate: Loader{
                property var model: modelData
                property var idx: index
                property int type: 1
                sourceComponent: {
                    if(modelData instanceof FluPaneItem){
                        return com_panel_item
                    }
                    if(modelData instanceof FluPaneItemHeader){
                        return com_panel_item_header
                    }
                    if(modelData instanceof FluPaneItemSeparator){
                        return com_panel_item_separatorr
                    }
                }
            }
        }
    }
    Popup{
        property var childModel
        id:control_popup
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from:0
                to:1
                duration: 83
            }
        }
        Connections{
            target: d
            function onIsCompactChanged(){
                if(!d.isCompact){
                    control_popup.close()
                }
            }
        }
        padding: 0
        focus: true
        contentItem: Item{
            ListView{
                id:list_view
                anchors.fill: parent
                clip: true
                currentIndex: -1
                model: control_popup.childModel
                ScrollBar.vertical: FluScrollBar {}
                delegate:Button{
                    id:item_button
                    width: 180
                    height: 38
                    focusPolicy:Qt.TabFocus
                    background: Rectangle{
                        color:  {
                            if(FluTheme.dark){
                                if(item_button.hovered){
                                    return Qt.rgba(1,1,1,0.06)
                                }
                                return Qt.rgba(0,0,0,0)
                            }else{
                                if(item_button.hovered){
                                    return Qt.rgba(0,0,0,0.03)
                                }
                                return Qt.rgba(0,0,0,0)
                            }
                        }
                        FluFocusRectangle{
                            visible: item_button.activeFocus
                            radius:4
                        }

                        Loader{
                            id:item_dot_loader
                            anchors{
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: 10
                            }
                            sourceComponent: {
                                if(model.infoBadge){
                                    return model.infoBadge
                                }
                                return undefined
                            }
                        }

                    }
                    contentItem: FluText{
                        text:modelData.title
                        elide: Text.ElideRight
                        rightPadding: item_dot_loader.width
                        verticalAlignment: Qt.AlignVCenter
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    onClicked: {
                        if(modelData.tapFunc){
                            modelData.tapFunc()
                        }else{
                            modelData.tap()
                            nav_list.currentIndex = idx
                            layout_footer.currentIndex = -1
                            if(d.isMinimal || d.isCompact){
                                d.enableNavigationPanel = false
                            }
                        }
                        control_popup.close()
                    }
                }
            }
        }
        background: FluRectangle{
            implicitWidth: 180
            implicitHeight: 38*Math.min(Math.max(list_view.count,1),8)
            radius: [4,4,4,4]
            FluShadow{
                radius: 4
            }
            color: FluTheme.dark ? Qt.rgba(51/255,48/255,48/255,1) : Qt.rgba(248/255,250/255,253/255,1)
        }
        function showPopup(pos,model){
            control_popup.x = pos.x
            control_popup.y = pos.y
            control_popup.childModel = model
            control_popup.open()
        }
    }
    Component{
        id:com_placeholder
        Item{
            property int pageMode: FluNavigationView.SingleInstance
            property string url
        }
    }
    function collapseAll(){
        for(var i=0;i<nav_list.model.length;i++){
            var item = nav_list.model[i]
            if(item instanceof FluPaneItemExpander){
                item.isExpand = false
            }
        }
    }
    function setCurrentIndex(index){
        nav_list.currentIndex = index
        var item = nav_list.model[index]
        if(item instanceof FluPaneItem){
            item.tap()
        }
    }
    function getItems(){
        return nav_list.model
    }
    function push(url,argument={}){
        var page = nav_swipe.find(function(item) {
            return item.url === url;
        })
        if(page){
            switch(page.pageMode)
            {
            case FluNavigationView.SingleTask:
                while(nav_swipe.currentItem !== page)
                {
                    FluTools.deleteItem(nav_swipe.pop())
                    d.stackItems.pop()
                }
                return
            case FluNavigationView.SingleTop:
                if (nav_swipe.currentItem.url === url){
                    return
                }
                break
            case FluNavigationView.Standard:
            default:
            }
        }

        var pageIndex = -1
        for(var i=0;i<nav_swipe2.children.length;i++){
            var item =  nav_swipe2.children[i]
            if(item.url === url){
                pageIndex = i
                break
            }
        }
        var options = Object.assign(argument,{url:url})
        if(pageIndex!==-1){
            nav_swipe2.currentIndex = pageIndex
            nav_swipe.push(com_placeholder,options)
        }else{
            var comp = Qt.createComponent(url)
            if (comp.status === Component.Ready) {
                var obj  = comp.createObject(nav_swipe,options)
                if(obj.pageMode === FluNavigationView.SingleInstance){
                    nav_swipe.push(com_placeholder,options)
                    nav_swipe2.children.push(obj)
                    nav_swipe2.currentIndex = nav_swipe2.count - 1
                }else{
                    nav_swipe.push(obj)
                }
            }else{
                console.error(comp.errorString())
            }
        }
        d.stackItems.push(nav_list.model[nav_list.currentIndex])
    }
    function getCurrentIndex(){
        return nav_list.currentIndex
    }
    function getCurrentUrl(){
        if(nav_swipe.currentItem){
            return nav_swipe.currentItem.url
        }
        return undefined
    }
    function startPageByItem(data){
        var items = getItems()
        for(var i=0;i<items.length;i++){
            var item =  items[i]
            if(item.key === data.key){
                if(getCurrentIndex() === i){
                    return
                }
                setCurrentIndex(i)
                if(item.parent && !d.isCompactAndNotPanel){
                    item.parent.isExpand = true
                }
                return
            }
        }
    }
    function backButton(){
        return btn_back
    }
    function navButton(){
        return btn_nav
    }
}
