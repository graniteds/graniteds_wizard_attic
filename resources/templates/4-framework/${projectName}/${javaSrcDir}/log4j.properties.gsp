<%
	if (!targetPlatform.startsWith("TC") && !targetPlatform.startsWith("JY"))
		throw new org.granite.generator.CancelFileGenerationException();
%>log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=%d{HH:mm:ss,SSS} %-5p [%c] - %m%n

log4j.rootLogger=INFO,A1
log4j.appender.A1.Target=System.out