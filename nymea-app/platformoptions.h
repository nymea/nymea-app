#ifndef PLATFORMOPTIONS_H
#define PLATFORMOPTIONS_H

#include <QObject>

class PlatformOptions : public QObject
{
    Q_OBJECT
public:
    explicit PlatformOptions(QObject *parent = nullptr);

signals:

public slots:
};

#endif // PLATFORMOPTIONS_H