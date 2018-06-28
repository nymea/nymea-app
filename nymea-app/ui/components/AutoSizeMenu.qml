import QtQuick 2.9
import QtQuick.Controls 2.2

Menu {
    function calculateWidth() {
        var result = 0;
        var i = 0;
        while (itemAt(i) !== null) {
            result = Math.max(itemAt(i).contentItem.implicitWidth + app.margins * 2, result);
            i++;
        }
        width = Math.min(parent.width, result + app.margins * 2);

    }
    onAboutToShow: calculateWidth()

}
