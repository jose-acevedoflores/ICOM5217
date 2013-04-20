#include <QtCore/QCoreApplication>
#include <QDebug>
#include <QTimer>
#include <qextserialport.h>

#include <iostream>
#include <fstream>
#include <string>
using namespace std;

#include "console.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    char* data = "";
    if (argc > 0) {
        data = argv[1];
    }

    Console *c = new Console(data);
    c->initializeSerialPort();

    return 0;
    //return a.exec();
}

