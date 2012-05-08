/***************************************************************************
 * Copyright 2012 by
 *  + Christian-Albrechts-University of Kiel
 *    + Department of Computer Science
 *      + Software Engineering Group 
 *  and others.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

package kieker.analysis.display;

/**
 * This is the abstract class which should be the base class for all other display types.
 * 
 * @author Nils Christian Ehmke
 */
public abstract class AbstractDisplay {

	public AbstractDisplay() {
		// No code necessary
	}

	/**
	 * Remove this method once other methods have been implemented in this class. It is just a place holder to avoid a high prioritized warning of pmd.
	 */
	@Override
	public String toString() {
		return super.toString();
	}
}