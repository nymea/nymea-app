#ifndef TIMEDESCRIPTOR_H
#define TIMEDESCRIPTOR_H

#include <QObject>

class TimeDescriptor : public QObject
{
    Q_OBJECT
public:
    explicit TimeDescriptor(QObject *parent = nullptr);

signals:

public slots:
};

#endif // TIMEDESCRIPTOR_H