// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Dialogs
import QtCore

CustomDialog {
    id: root

    property string defaultPath: "file:///" + effectManager.projectDirectory + "/export"
    title: qsTr("Export Effect")
    width: 540
    height: 580
    modal: true
    focus: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Popup.NoAutoClose

    onAboutToShow: {
        nameTextEdit.text = initialName();
        pathTextEdit.text = initialPath();
        // Note: These must match with EffectManager ExportFlags
        qmlComponentCheckBox.checked = (effectManager.exportFlags & 1);
        qbsShadersCheckBox.checked = (effectManager.exportFlags & 2);
        plainShadersCheckBox.checked = (effectManager.exportFlags & 4);
        imagesCheckBox.checked = (effectManager.exportFlags & 8);
        qrcCheckBox.checked = (effectManager.exportFlags & 16);
    }

    function initialName() {
        if (effectManager.exportFilename != "") {
            return effectManager.exportFilename;
        } else {
            // Returns project name, making sure first letter is uppercase
            var str = effectManager.projectName;
            str = str.charAt(0).toUpperCase() + str.slice(1);
            return str;
        }
    }

    function initialPath() {
        if (effectManager.exportDirectory != "")
            return effectManager.stripFileFromURL(effectManager.exportDirectory);
        else
            return effectManager.stripFileFromURL(defaultPath);
    }

    FolderDialog {
        id: projectPathDialog
        currentFolder: defaultPath
        onAccepted: {
            if (currentFolder) {
                // Remove file start
                var usedFolder = effectManager.stripFileFromURL(currentFolder.toString());
                pathTextEdit.text = usedFolder;
            }
        }
    }

    GridLayout {
        id: detailsArea
        width: parent.width
        columns: 3
        columnSpacing: 20
        Label {
            text: qsTr("Name:")
            font.bold: true
            font.pixelSize: 14
            color: mainView.foregroundColor2
        }
        TextField {
            id: nameTextEdit
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }
        Label {
            text: qsTr("Create in:")
            font.bold: true
            font.pixelSize: 14
            color: mainView.foregroundColor2
        }
        TextField {
            id: pathTextEdit
            Layout.fillWidth: true
        }
        Button {
            text: qsTr("Browse");
            onClicked: {
                projectPathDialog.open();
            }
        }
    }
    Column {
        id: settingsArea
        width: parent.width
        anchors.top: detailsArea.bottom
        anchors.topMargin: 20
        Label {
            text: qsTr("Exported files:")
            font.bold: true
            font.pixelSize: 14
            color: mainView.foregroundColor2
        }
        CheckBox {
            id: qmlComponentCheckBox
            text: "QML component"
            checked: true
        }
        CheckBox {
            id: qbsShadersCheckBox
            text: "Binary shaders (qsb)"
            checked: true
        }
        CheckBox {
            id: plainShadersCheckBox
            text: "Plain-text shaders"
            checked: true
        }
        CheckBox {
            id: imagesCheckBox
            text: "Images"
            checked: true
        }
        CheckBox {
            id: qrcCheckBox
            text: "Resource collection file (qrc)"
            checked: true
        }
    }
    onAccepted: {
        var exportFlags = 0;
        // Note: These must match with EffectManager ExportFlags
        exportFlags += Number(qmlComponentCheckBox.checked) * 1;
        exportFlags += Number(qbsShadersCheckBox.checked) * 2;
        exportFlags += Number(plainShadersCheckBox.checked) * 4;
        exportFlags += Number(imagesCheckBox.checked) * 8;
        exportFlags += Number(qrcCheckBox.checked) * 16;
        effectManager.exportEffect(pathTextEdit.text, nameTextEdit.text, exportFlags);
    }
}