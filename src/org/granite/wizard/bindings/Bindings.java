/*
  GRANITE DATA SERVICES
  Copyright (C) 2011 GRANITE DATA SERVICES S.A.S.

  This file is part of Granite Data Services.

  Granite Data Services is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  Granite Data Services is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, see <http://www.gnu.org/licenses/>.
*/

package org.granite.wizard.bindings;

import groovy.lang.Binding;
import groovy.lang.GroovyShell;
import groovy.lang.Script;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.codehaus.groovy.control.CompilationFailedException;
import org.codehaus.groovy.runtime.InvokerHelper;

/**
 * @author Franck WOLFF
 */
public class Bindings {

	private final List<Variable> variables;
	private final Map<String, Map<String, Object>> variablesMap;
	
	@SuppressWarnings("unchecked")
	public Bindings(File source) throws CompilationFailedException, IOException {
		
		GroovyShell shell = new GroovyShell(getClass().getClassLoader());
		Script script = shell.parse(source);
		Script scriptInstance = InvokerHelper.createScript(script.getClass(), new Binding());
		scriptInstance.run();
		
		this.variablesMap = scriptInstance.getBinding().getVariables();
		
		this.variables = new ArrayList<Variable>();
		for (Map.Entry<String, Map<String, Object>> entry : variablesMap.entrySet()) {
			Variable variable = new Variable(entry.getKey(), entry.getValue());
			variables.add(variable);
		}
	}
	
	public List<Variable> getVariables() {
		return variables;
	}
	
	public Variable getVariable(String name) {
		for (Variable variable : variables) {
			if (variable.getName().equals(name))
				return variable;
		}
		return null;
	}
	
	public Map<String, Object> getBindingMap() {
		Map<String, Object> map = new HashMap<String, Object>();
		for (Variable variable : variables)
			map.put(variable.getName(), variable.getValue());
		return map;
	}
}
