#ifndef STYLECONTROLLER_H
#define STYLECONTROLLER_H

#include <QObject>

class StyleController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentStyle READ currentStyle WRITE setCurrentStyle NOTIFY currentStyleChanged)
    Q_PROPERTY(QStringList allStyles READ allStyles CONSTANT)

public:
    explicit StyleController(QObject *parent = nullptr);

    QString currentStyle() const;
    void setCurrentStyle(const QString &currentStyle);

    QStringList allStyles() const;

signals:
    void currentStyleChanged();

};

#endif // STYLECONTROLLER_H
