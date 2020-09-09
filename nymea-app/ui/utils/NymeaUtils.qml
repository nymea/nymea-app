pragma Singleton
import QtQuick 2.9

Item {
    id: root

    function pad(num, size) {
        var trimmedNum = Math.floor(num)
        var decimals = num - trimmedNum
        var trimmedStr = "" + trimmedNum
        var str = "000000000" + trimmedNum;
        str = str.substr(str.length - Math.max(size, trimmedStr.length));
        if (decimals !== 0) {
            str += "." + (num - trimmedNum);
        }
        return str;
    }
}
