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

package kieker.analysis.plugin.reader.list;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CountDownLatch;

import kieker.analysis.plugin.annotation.OutputPort;
import kieker.analysis.plugin.annotation.Plugin;
import kieker.analysis.plugin.annotation.Property;
import kieker.analysis.plugin.reader.AbstractReaderPlugin;
import kieker.common.configuration.Configuration;
import kieker.common.logging.Log;
import kieker.common.logging.LogFactory;

/**
 * Helper class that reads records added using the method {@link #addAllRecords(List)}.
 * Depending on the value of the {@link Configuration} variable {@value #CONFIG_PROPERTY_NAME_AWAIT_TERMINATION},
 * either the {@link #read()} method returns immediately, or awaits a termination via {@link kieker.analysis.AnalysisController#terminate()}.
 * 
 * @param <T>
 * 
 * @author Andre van Hoorn, Jan Waller
 */
@Plugin(programmaticOnly = true,
		description = "A reader that can be prefilled programmatically and that provides these records (mostly used in testing scenarios)",
		outputPorts = @OutputPort(name = ListReader.OUTPUT_PORT_NAME, eventTypes = { Object.class }),
		configuration = {
			@Property(name = ListReader.CONFIG_PROPERTY_NAME_AWAIT_TERMINATION, defaultValue = "false",
					description = "Determines whether the read()-method returns immediately or whether it awaits the termination via AnalysisController.terminate()")
		})
public class ListReader<T> extends AbstractReaderPlugin {

	public static final String OUTPUT_PORT_NAME = "defaultOutput";

	public static final String CONFIG_PROPERTY_NAME_AWAIT_TERMINATION = "awaitTermination";

	private static final Log LOG = LogFactory.getLog(ListReader.class);

	private final boolean awaitTermination;
	private final CountDownLatch terminationLatch = new CountDownLatch(1);

	private final List<T> objects = new CopyOnWriteArrayList<T>();

	public ListReader(final Configuration configuration) {
		super(configuration);
		this.awaitTermination = configuration.getBooleanProperty(CONFIG_PROPERTY_NAME_AWAIT_TERMINATION);
		if (!this.awaitTermination) {
			this.terminationLatch.countDown(); // just to be sure that a call to await() would return immediately
		}
	}

	public void addAllObjects(final List<T> records) {
		this.objects.addAll(records);
	}

	public void addObject(final T object) {
		this.objects.add(object);
	}

	public boolean read() {
		for (final T obj : this.objects) {
			super.deliver(ListReader.OUTPUT_PORT_NAME, obj);
		}
		try {
			if (this.awaitTermination) {
				LOG.info("Awaiting termination latch to count down ...");
				this.terminationLatch.await();
				LOG.info("Passed termination latch");
			}
		} catch (final InterruptedException e) {
			LOG.error("Reader interrupted while awaiting termination", e);
			return false;
		}
		return true;
	}

	public void terminate(final boolean error) {
		this.terminationLatch.countDown();
	}

	public Configuration getCurrentConfiguration() {
		final Configuration configuration = new Configuration();
		configuration.setProperty(CONFIG_PROPERTY_NAME_AWAIT_TERMINATION, Boolean.toString(this.awaitTermination));
		return configuration;
	}
}