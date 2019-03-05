#ifndef STYLECONTROLLER_H
#define STYLECONTROLLER_H

#include <QObject>

class StyleController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentStyle READ currentStyle WRITE setCurrentStyle NOTIFY currentStyleChanged)
    Q_PROPERTY(QStringList allStyles READ allStyles CONSTANT)

    Q_PROPERTY(QString currentExperience READ currentExperience WRITE setCurrentExperience NOTIFY currentExperienceChanged)
    Q_PROPERTY(QStringList allExperiences READ allExperiences CONSTANT)

public:
    explicit StyleController(QObject *parent = nullptr);

    QString currentStyle() const;
    void setCurrentStyle(const QString &currentStyle);

    QStringList allStyles() const;

    QString currentExperience() const;
    void setCurrentExperience(const QString &currentExperience);

    QStringList allExperiences() const;

signals:
    void currentStyleChanged();
    void currentExperienceChanged();

};

#endif // STYLECONTROLLER_H
