package main.freesteel;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Random;
import javax.swing.ProgressMonitor;
import javax.swing.SwingWorker;
import javax.swing.filechooser.FileNameExtensionFilter;

import main.view.MainFrame;


/**
 * This class will be in charge of generating the sequence of BMP images the LCr will project
 * @author joseacevedo
 *
 */
public class FreeSteelSlice {

	//This two static fields are used to enable all the components with a FreeSteelSlice object to access 
	// the FILE_NAME and the LAYER_THICKNESS 
	public static String STL_FILE_NAME = "!" ;
	public static double LAYER_THICKNESS = 1.5;
	public static String ETA = "!";
	public static int NUMBER_OF_LAYERS = 0;

	private String sliceScriptPath;
	private String freeSteelOutput;
	private String currentPath;
	private MainFrame viewReferences; 

	private ProgressMonitor progressMonitor;
	private static Task task;

	/**
	 * Creates a new FreeSteel Runtime component to access the Python script of FreeSteel
	 */
	public FreeSteelSlice(MainFrame frame)
	{
		viewReferences  = frame;
		sliceScriptPath = "resources/FreeSteel/freeSteel_Linux_script/slice.py";
		freeSteelOutput = "freeSteelGeneratedBMPs/";
	}

	/**
	 * This method slices the STL file in bmp images
	 */
	public void slice()
	{

		if(System.getProperty("os.name").equals("Linux"))
		{
			if(!STL_FILE_NAME.equals("!") )
			{
				//System.out.println(STL_FILE_NAME+" -- "+LAYER_THICKNESS);

				progressMonitor = new ProgressMonitor(viewReferences, "Generating bitmaps",
						"", 0, 100);
				task = new Task();
				task.addPropertyChangeListener(new ProgressListener());
				task.execute();

			}
			else 
				System.out.println("File or layer thickness not initialized");
		}
		else
			System.out.println(System.getProperty("os.name")+" is not supported by freeSteel");


	}

	/**
	 * 
	 * @author jose
	 *
	 */
	private class Task extends SwingWorker<Void, Void>
	{

		@Override
		protected Void doInBackground() throws Exception {
			setProgress(0);
			try {
				currentPath = System.getProperty("user.dir");

				String scriptLocation = currentPath+"/"+sliceScriptPath;
				String options = "-z -15,130,"+LAYER_THICKNESS;
				String outputLocation = currentPath+"/"+freeSteelOutput+"test.bmp";
				String cmd[] = {"python", scriptLocation, options,
						STL_FILE_NAME, "-o", outputLocation};

				for(String str : cmd)
					System.out.println(str);


				Process p = Runtime.getRuntime().exec(cmd);
				File freeSteelBMPs = new File(currentPath+"/"+freeSteelOutput);
				String[] bmps;
				int progress =0;
				double size = (135/LAYER_THICKNESS);
				
				while (progress < 100 && !isCancelled()) {
						
					bmps = freeSteelBMPs.list();
					//Sleep for up to one second.
					Thread.sleep(1000);
					System.out.println("Progress "+progress);
					progress = (int) (bmps.length / size*100);
					setProgress(progress);
				}

				System.out.println("Return value "+p.waitFor());

			} catch (IOException e) {

				e.printStackTrace();
			} 
			return null;

		}

		@Override
		public void done()
		{
			System.out.println("Woot WOot");
			progressMonitor.setProgress(100);
			//The substring here gets the original content of the JLabel (Number of layers:) and adds the new computed number of layers
			viewReferences.numOfLayers.setText(viewReferences.numOfLayers.getText().substring(0, 17)+ " 200");
		}


	}
	
	/**
	 * 
	 * @author jose
	 *
	 */
	private class ProgressListener implements PropertyChangeListener{

		@Override
		public void propertyChange(PropertyChangeEvent evt) {

			
			if(evt.getPropertyName().equals("progress"))
			{			
				progressMonitor.setProgress((Integer) evt.getNewValue());
				String message =
						String.format("Completed %d%%.\n", (Integer) evt.getNewValue());
				progressMonitor.setNote(message);
				if (progressMonitor.isCanceled() || task.isDone()) 
				{

					if (progressMonitor.isCanceled()) 
					{
						task.cancel(true);
						System.out.println("Task cancelled");
					} 
					else 
						System.out.println("Task Completed");


				}
			}
		}

	}
	
	

}
