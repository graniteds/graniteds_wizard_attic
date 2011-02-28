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

import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.RegistryFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.Version;

/**
 * @author Franck WOLFF
 */
public class Eclipse {

	public static boolean hasExtension(String id) {
		IExtensionRegistry reg = RegistryFactory.getRegistry();
		if (reg != null)
			return reg.getExtension(id) != null;
		return false;
	}

	public static boolean hasBundle(String id) {
		return Platform.getBundle(id) != null;
	}

	public static Version getBundleVersion(String id) {
		Bundle bundle = Platform.getBundle(id);
		if (bundle != null)
			return bundle.getVersion();
		return new Version(-1, -1, -1, "null");
	}
}
