/*
 * ==================LICENCE=========================
 * Copyright 2006-2010 Kieker Project
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
 * ==================================================
 */

package kieker.tpan.plugins.traceReconstruction;

import kieker.tpan.ITpanControlledComponent;
import kieker.tpan.datamodel.factories.SystemEntityFactory;

/**
 *
 * @author Andre van Hoorn
 */
public abstract class AbstractTpanTraceProcessingComponent implements ITpanControlledComponent {
    private int numTracesProcessed = 0;
    private int numTracesSucceeded = 0;
    private int numTracesFailed = 0;

    private long lastTraceIdSuccess = -1;
    private long lastTraceIdError = -1;

    private final String name;
    private final SystemEntityFactory systemEntityFactory;

    private AbstractTpanTraceProcessingComponent(){
        this.name = "no name";
        this.systemEntityFactory = null;
    }

    public AbstractTpanTraceProcessingComponent (final String name, 
            final SystemEntityFactory systemEntityFactory){
        this.systemEntityFactory = systemEntityFactory;
        this.name = name;
    }

    protected final void reportSuccess(final long traceId){
        this.lastTraceIdSuccess = traceId;
        this.numTracesSucceeded++;
        this.numTracesProcessed++;
    }

    protected final void reportError(final long traceId){
        this.lastTraceIdError = traceId;
        this.numTracesFailed++;
        this.numTracesProcessed++;
    }

    public final int getSuccessCount(){
        return this.numTracesSucceeded;
    }

    public final int getErrorCount(){
        return this.numTracesFailed;
    }

    public final int getTotalCount(){
        return this.numTracesProcessed;
    }

    public final long getLastTraceIdError() {
        return lastTraceIdError;
    }

    public final long getLastTraceIdSuccess() {
        return lastTraceIdSuccess;
    }

    protected void printMessage(final String[] lines){
        System.out.println("");
        System.out.println("#");
        System.out.println("# Plugin: " + this.name);
        for (String l : lines){
            System.out.println(l);
        }
    }

    public void printStatusMessage(){
        this.printMessage(new String[] {
            "Trace processing summary: "
                    + this.numTracesProcessed + " total; "
                    + this.numTracesSucceeded + " succeeded; "
                    + this.numTracesFailed + " failed."
        });
    }

   protected final SystemEntityFactory getSystemEntityFactory() {
        return this.systemEntityFactory;
    }
}
