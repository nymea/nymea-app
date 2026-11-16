// SPDX-License-Identifier: GPL-3.0-or-later

#include <QtTest>

#include "connection/nymeahost.h"

class TestProductInfo : public QObject
{
    Q_OBJECT

private slots:
    void hostKeepsProductInfoSeparate();
};

void TestProductInfo::hostKeepsProductInfoSeparate()
{
    NymeaHost first;
    NymeaHost second;
    QSignalSpy changed(&first, &NymeaHost::productInfoChanged);

    QCOMPARE(first.vendor(), QString());
    QCOMPARE(first.vendorurl(), QString());
    QCOMPARE(first.model(), QString());
    QCOMPARE(first.hardwareRevision(), QString());
    QCOMPARE(first.producttype(), QString());

    // Discovery provides only the values advertised in TXT.
    first.setProductInfo("Example Vendor", {}, "Model A", {}, "wallbox");
    QCOMPARE(changed.count(), 1);
    QCOMPARE(first.vendor(), QString("Example Vendor"));
    QCOMPARE(first.model(), QString("Model A"));
    QCOMPARE(first.producttype(), QString("wallbox"));
    QCOMPARE(second.vendor(), QString());

    // Hello replaces discovery data, including empty fields.
    first.setProductInfo("Other vendor", "https://example.org/", "Model B", "V2", "gateway");
    QCOMPARE(changed.count(), 2);
    QCOMPARE(first.vendorurl(), QString("https://example.org/"));
    QCOMPARE(first.hardwareRevision(), QString("V2"));

    first.setProductInfo({}, {}, {}, {}, {});
    QCOMPARE(changed.count(), 3);
    QCOMPARE(first.vendor(), QString());
    QCOMPARE(first.vendorurl(), QString());
    QCOMPARE(first.model(), QString());
    QCOMPARE(first.hardwareRevision(), QString());
    QCOMPARE(first.producttype(), QString());

    first.setProductInfo({}, {}, {}, {}, {});
    QCOMPARE(changed.count(), 3);
}

QTEST_GUILESS_MAIN(TestProductInfo)
#include "tst_productinfo.moc"
