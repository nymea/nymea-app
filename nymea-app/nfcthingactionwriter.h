#ifndef NFCTHINGACTIONWRITER_H
#define NFCTHINGACTIONWRITER_H

#include <QObject>
#include <QNearFieldManager>
#include <QNdefMessage>

#include "types/thing.h"
#include "engine.h"
#include "types/ruleactions.h"

class NfcThingActionWriter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAvailable READ isAvailable CONSTANT)
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(Thing *thing READ thing WRITE setThing NOTIFY thingChanged)
    Q_PROPERTY(RuleActions *actions READ actions CONSTANT)
    Q_PROPERTY(int messageSize READ messageSize NOTIFY messageSizeChanged)
    Q_PROPERTY(TagStatus status READ status NOTIFY statusChanged)


public:
    enum TagStatus {
        TagStatusWaiting,
        TagStatusWriting,
        TagStatusWritten,
        TagStatusFailed
    };
    Q_ENUM(TagStatus)

    static NfcThingActionWriter *instance();

    explicit NfcThingActionWriter(QObject *parent = nullptr);
    ~NfcThingActionWriter();

    bool isAvailable() const;

    Engine *engine() const;
    void setEngine(Engine *engine);

    Thing *thing() const;
    void setThing(Thing *thing);

    RuleActions *actions() const;

    int messageSize() const;

    TagStatus status() const;

signals:
    void engineChanged();
    void thingChanged();

    void messageSizeChanged();
    void statusChanged();

private slots:
    void updateContent();

    void targetDetected(QNearFieldTarget *target);
    void targetLost(QNearFieldTarget *target);

private:
    QNearFieldManager *m_manager = nullptr;
    Engine *m_engine = nullptr;
    Thing *m_thing = nullptr;
    RuleActions* m_actions;

    TagStatus m_status = TagStatusWaiting;

    QNdefMessage m_currentMessage;

};

#endif // NFCTHINGACTIONWRITER_H
