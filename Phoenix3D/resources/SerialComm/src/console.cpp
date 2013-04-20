#include <qextserialport.h>
#include <QtCore>
#include <iostream>
#include <fstream>
#include "console.h"


Console::Console(char* fn)
{
    // Timer functions no longer needed
    timer = new QTimer();
    timer->setInterval(40);
    connect(timer, SIGNAL(timeout()), this, SLOT(readShouldBeReady()));
    data = fn;

}

bool Console::initializeSerialPort() {
    PortSettings settings = {BAUD9600, DATA_8, PAR_NONE, STOP_1, FLOW_OFF, 10};
    port = new QextSerialPort("/dev/ttyUSB0", settings, QextSerialPort::Polling);

    port->setPortName("/dev/ttyUSB0");
    bool result = port->open(QIODevice::ReadWrite);

    if (result) {
        qDebug("Serial port opened successfully.");
        qDebug("To send: ");
        qDebug(data);
        port->write(data);
        qDebug("Information successfully sent");
       // exit(0);
       // timer->start();
    }

    return result;
}

void Console::readShouldBeReady() {
    //qDebug("Timer tick...");
    if (port->bytesAvailable()) {
        QByteArray array = port->readAll();
        if (array.data() == "x") {
            qDebug("Communication successful");
            exit(0);
        }

        qDebug(port->readAll());

    }
}

