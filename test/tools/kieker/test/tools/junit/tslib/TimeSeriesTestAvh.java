/***************************************************************************
 * Copyright 2012 Kieker Project (http://kieker-monitoring.net)
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

package kieker.test.tools.junit.tslib;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import junit.framework.Assert;
import junit.framework.TestCase;

import org.junit.Test;

import kieker.tools.tslib.TimeSeries;

/**
 * Some tests in addition to {@link TimeSeriesTest}. Since I'm following a slightly different style of writing tests
 * (refuse state in tests), I've decided to add the tests to a separate class. Might be consolidated later.
 * 
 * @author Andre van Hoorn
 * 
 */
public class TimeSeriesTestAvh extends TestCase {
	final long startTime = 98890787;
	final long deltaTimeMillis = 1000;

	@Test
	public void testAppendAll() {
		final Double[] values = { 600.9, 400.2, 223.9 };
		final List<Double> expectedValues = new ArrayList<Double>(values.length);
		for (final Double curVal : values) {
			expectedValues.add(curVal);
		}

		final TimeSeries<Double> ts = new TimeSeries<Double>(new Date(this.startTime), this.deltaTimeMillis, TimeUnit.MILLISECONDS);
		ts.appendAll(values);

		final List<Double> tsValues = ts.getValues();

		Assert.assertEquals("Unexpected size of time series", values.length, ts.size());
		Assert.assertEquals("Unexpected size of values list", values.length, tsValues.size());

		Assert.assertEquals("values not equal", expectedValues, tsValues);
	}
}