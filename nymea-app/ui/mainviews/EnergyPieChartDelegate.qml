import QtQuick 2.3
import QtCharts 2.2

Item {
    id: sliceItem
    property PieSeries series: null
    property Thing thing: model.get(index)
    property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    property PieSlice consumerSlice: null
    property PieSlice producerSlice: null
    Component.onCompleted: {
        if (currentPowerState.value >= 0) {
            consumerSlice = consumersSeries.append(thing.name, currentPowerState.value)
            prodcuersSlice = producerSeries.append(thing.name, 0)
        } else {
            consumerSlice = consumersSeries.append(thing.name, 0)
            prodcuersSlice = producerSeries.append(thing.name, Math.abs(currentPowerState.value))
        }
    }
    Connections {
        target: currentPowerState
        onValueChanged: {
            if (currentPowerState.value >= 0) {
                consumerSlice.value = currentPowerState.value
                producerSlice.value = 0
            } else {
                consumerSlice.value = 0
                producerSlice.value = Math.abs(currentPowerState.value)
            }
        }
    }

    Component.onDestruction: {
        consumersSeries.remove(slice)
    }
}
