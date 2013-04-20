#ifndef CONSOLE_H
#define CONSOLE_H

#include <QObject>
using namespace std;

class QTimer;
class QextSerialPort;

class Console : public QObject
{
    Q_OBJECT

public:
    Console(char *fn);
    bool initializeSerialPort();
    void loadTargetFile();

private slots:
    void readShouldBeReady();

private:
    QTimer *timer;
    QextSerialPort *port;
    string fileContents[6];
    char* data;

};

#endif // CONSOLE_H
