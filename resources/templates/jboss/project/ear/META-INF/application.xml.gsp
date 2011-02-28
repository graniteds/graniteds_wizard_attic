<?xml version="1.0" encoding="UTF-8"?>

<application
	xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/application_5.xsd"
	version="5">

	<description>${projectName} Enterprise Application Description</description>
    <display-name>${projectName} Enterprise Application</display-name>

    <module>
        <web>
            <web-uri>${projectName}.war</web-uri>
            <context-root>/${projectName}</context-root>
        </web>
    </module>

    <module>
        <ejb>${projectName}.jar</ejb>
    </module>
</application>
