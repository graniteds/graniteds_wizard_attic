<% if (!antBuild)
		throw new org.granite.generator.CancelFileGenerationException();

%><?xml version="1.0" encoding="UTF-8"?>

<project name="${projectName}" default="build.war" xmlns:ivy="antlib:org.apache.ivy.ant">
	
	<!--
	 ! Load configuration properties from the 'env.properties' file.
	 !-->
	<property file="env.properties"/>

	<property environment="env"/>
	<property name="war.dir" value="\${build.dir}/\${project.name}"/>

	<!-- 
	 ! Ivy setup 
	 !-->
	<property name="ivy.install.version" value="2.2.0" />
	<condition property="ivy.home" value="\${env.IVY_HOME}">
		<isset property="env.IVY_HOME" />
	</condition>
	<property name="ivy.home" value="\${user.home}/.ant" />
	<property name="ivy.jar.dir" value="\${ivy.home}/lib" />
	<property name="ivy.jar.file" value="\${ivy.jar.dir}/ivy.jar" />

	<target name="ivy.download" unless="offline">
		<mkdir dir="\${ivy.jar.dir}"/>
	    <!-- download Ivy from web site so that it can be used even without any special installation -->
	    <get src="http://repo2.maven.org/maven2/org/apache/ivy/ivy/\${ivy.install.version}/ivy-\${ivy.install.version}.jar" 
	             dest="\${ivy.jar.file}" usetimestamp="true"/>
	</target>

	<target name="ivy.init" depends="ivy.download">
		<!-- try to load ivy here from ivy home, in case the user has not already dropped
	    	 it into ant's lib dir (note that the latter copy will always take precedence).
	         We will not fail as long as local lib dir exists (it may be empty) and
	         ivy is in at least one of ant's lib dir or the local lib dir. -->
	    <path id="ivy.lib.path">
	    	<fileset dir="\${ivy.jar.dir}" includes="*.jar"/>
	    </path>
	    <taskdef resource="org/apache/ivy/ant/antlib.xml" uri="antlib:org.apache.ivy.ant" classpathref="ivy.lib.path"/>
	</target>
	
	<target name="ivy.resolve" depends="ivy.init">
		<ivy:retrieve pattern="lib/[artifact].[ext]" conf="*" type="jar,swc"/>
	</target>

	<% if (javaPersistence == "DataNucleus") { %>
    <!--
     ! DataNucleus specific (run the enhancer).
     !-->	
	<path id="datanucleus.enhancer.classpath">
		<fileset dir="lib">
			<include name="asm.jar"/>
			<include name="datanucleus-core.jar"/>
			<include name="datanucleus-enhancer.jar"/>
			<include name="datanucleus-api-jpa.jar"/>
			<include name="jdo2-api.jar"/>
			<include name="hibernate-jpa-2.0-api.jar"/>
			<include name="granite-core.jar"/>
		</fileset>
	</path>
	<taskdef name="datanucleusenhancer" classpathref="datanucleus.enhancer.classpath" 
        classname="org.datanucleus.enhancer.tools.EnhancerTask" onerror="ignore"/>
	
	<target name="datanucleus.enhance" depends="ivy.resolve"
		description="DataNucleus specific (run the enhancer)">

	    <datanucleusenhancer api="JPA" dir="." failonerror="true" verbose="true">
	        <fileset dir="bin-java">
	            <include name="${Fs.dotsToSlashes(packageName)}/entities/**/*.class"/>
	    	</fileset>
	        <classpath>
	            <path refid="datanucleus.enhancer.classpath"/>
	        	<path location="bin-java"/>
	        </classpath>
	    </datanucleusenhancer>
	</target><%
	} else if (javaPersistence == "OpenJPA") { %>
    <!--
     ! OpenJPA specific (run the enhancer).
     !-->	
	<path id="openjpa.enhancer.classpath">
		<fileset dir="lib">
			<include name="openjpa-all.jar"/>
			<include name="granite-core.jar"/>
		</fileset>
	</path>
	<taskdef name="openjpac" classpathref="openjpa.enhancer.classpath" 
        classname="org.apache.openjpa.ant.PCEnhancerTask" onerror="ignore"/>
	
	<target name="openjpa.enhance" depends="ivy.resolve"
		description="OpenJPA specific (run the enhancer)">

	    <openjpac>
	    	<config propertiesFile="java/META-INF/persistence.xml"/>
	    	<classpath refid="openjpa.enhancer.classpath"/>
	    	<classpath location="bin-java"/>
	        <fileset dir="bin-java">
	            <include name="org/example/entities/*.class"/>
	        	<exclude name="org/example/entities/*\$*.class"/>
	    	</fileset>
	    </openjpac>
	</target><%
	}%>
	
	<!--
	 ! Build WAR.
	 !-->
	<target name="build.war" depends="ivy.resolve<% if (!flexBuilder) {%>, build.flex<% } %>">

		<mkdir dir="\${war.dir}"/>
		<copy todir="\${war.dir}">
			<fileset dir="WebContent" includes="**"/>
			<fileset dir="\${flex.bin.dir}" includes="**" excludes="**/*.cache"/>
		</copy>
		<copy todir="\${war.dir}/WEB-INF/classes">
			<fileset dir="\${java.bin.dir}" includes="**"/>
		</copy>
		<copy todir="\${war.dir}/WEB-INF/lib">
			<fileset dir="lib" includes="*.jar"><%
	if (targetPlatform.startsWith("JB4") || targetPlatform.startsWith("JB5") || targetPlatform.indexOf("(EE6)") >= 0) {%>
				<exclude name="hibernate*.jar"/>
				<exclude name="antlr.jar"/>
				<exclude name="dom4j.jar"/>
				<exclude name="slf4j*.jar"/>
				<exclude name="hsqldb.jar"/>
				<exclude name="javaee-api.jar"/>
				<exclude name="jsr250-api.jar"/>
				<exclude name="validation-api.jar"/>
				<exclude name="transaction-api.jar"/><%
	}
	if (targetPlatform.indexOf("(EE6)") >= 0) {%>
				<exclude name="jsf-api.jar"/><%
	}%>
			</fileset>			
		</copy>
		
		<zip destfile="\${war.dir}.war">
			<fileset dir="\${war.dir}" includes="**"/>
		</zip>
		
	</target>
	
	<!--
	 ! Deploy WAR.
	 !-->
	<target name="deploy.war" depends="build.war">

		<copy todir="\${deploy.dir}">
			<fileset dir="\${build.dir}" includes="\${project.name}.war"/>
		</copy>
		
	</target>
	
	<!--
	 ! Compile Flex sources and create a HTML wrapper.
	 !-->	
	<target name="build.flex" depends="ivy.resolve">
		
		<property name="FLEX_HOME" value="\${flex.home}"/>
		<taskdef resource="flexTasks.tasks" classpath="\${flex.home}/ant/lib/flexTasks.jar" />
		
		<mkdir dir="\${flex.bin.dir}"/>
		<mxmlc
            file="\${flex.src.dir}/\${project.name}.mxml"
            output="\${flex.bin.dir}/\${project.name}.swf"
            keep-generated-actionscript="false"
            debug="false"
            use-network="false">

            <source-path path-element="\${flex.home}/frameworks"/>
            <load-config filename="\${flex.home}/frameworks/flex-config.xml"/>
        	
        	<!-- Standard annotations -->
			<keep-as3-metadata name="Bindable"/>
		    <keep-as3-metadata name="Managed"/>
		    <keep-as3-metadata name="ChangeEvent"/>
		    <keep-as3-metadata name="NonCommittingChangeEvent"/>
		    <keep-as3-metadata name="Transient"/>

        	<!-- Tide annotations -->
        	<keep-as3-metadata name="Id"/>
        	<keep-as3-metadata name="Version"/>
        	<keep-as3-metadata name="Lazy"/>
        	<keep-as3-metadata name="Name"/>
        	<keep-as3-metadata name="In"/>
        	<keep-as3-metadata name="Out"/>
        	<keep-as3-metadata name="Inject"/>
        	<keep-as3-metadata name="Producer"/>
        	<keep-as3-metadata name="Observer"/>
        	<keep-as3-metadata name="ManagedEvent"/>
        	<keep-as3-metadata name="PostConstruct"/>
        	<keep-as3-metadata name="Destroy"/>

        	<!-- All granite-essentials.swc classes are included in the output swf -->
            <compiler.include-libraries dir="lib" append="true">
                <include name="granite-essentials.swc" />
            </compiler.include-libraries>

        	<!-- Only granite.swc actually used classes are included in the output swf -->
        	<compiler.library-path dir="lib" append="true">
        		<include name="granite-swc.swc"/>
        	</compiler.library-path>
        </mxmlc>

		<html-wrapper
			title="\${project.name}"
		    output="\${flex.bin.dir}"
			file="\${project.name}.html"
		    application="\${project.name}"
		    swf="${projectName}"
		    version-major="10"
		    version-minor="0"
		    version-revision="0"
		    history="true"
		    height="100%"
			width="100%"
		    bgcolor="#ffffff"
		/>

	</target>

</project>