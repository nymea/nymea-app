function Component()
{
    gui.pageWidgetByObjectName("LicenseAgreementPage").entered.connect(changeLicenseLabels);
}

changeLicenseLabels = function()
{
    page = gui.pageWidgetByObjectName("LicenseAgreementPage");
    page.AcceptLicenseLabel.setText("Yes, I agree");
    page.RejectLicenseLabel.setText("No, I disagree");
}

Component.prototype.createOperations = function()
{
    component.createOperations();

    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/maveo.exe", "@StartMenuDir@/Maveo Pro Box Dashboard.lnk",
            "workingDirectory=@TargetDir@", "iconPath=@TargetDir@/logo.ico",
            "description=Maveo Pro Box Dashboard");
    }
}
