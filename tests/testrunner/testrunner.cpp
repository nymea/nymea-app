
#include <QtQuickTest/quicktest.h>
#include <QtCore/qstring.h>
#include <QtQml>
#ifdef QT_OPENGL_LIB
#include <QtOpenGL/qgl.h>
#endif

#include "libmea-core.h"

int main(int argc, char **argv)
{
    registerQmlTypes();

    return quick_test_main(argc, argv, "qmltestrunner", ".");
}
