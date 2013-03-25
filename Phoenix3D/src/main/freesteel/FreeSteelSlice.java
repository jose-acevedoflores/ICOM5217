package main.freesteel;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

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
	private MainFrame viewReferences; 

	/**
	 * Creates a new FreeSteel Runtime component to access the Python script of FreeSteel
	 */
	public FreeSteelSlice(MainFrame frame)
	{
		viewReferences = frame;
		sliceScriptPath = "resources/FreeSteel/freeSteel_Linux_script/pythonTest.py";
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
				System.out.println(STL_FILE_NAME+" -- "+LAYER_THICKNESS);
				//The substring here gets the original content of the JLabel (Number of layers:) and adds the new computed number of layers
				viewReferences.numOfLayers.setText(viewReferences.numOfLayers.getText().substring(0, 17)+ " 200");
				
				try {
					String cmd[] = {"python", "/home/jose/Documents/ICOM5217/Phoenix3D/"+sliceScriptPath};
					Process p = Runtime.getRuntime().exec(cmd);
					BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
					p.waitFor();
					
					while(br.ready())
						System.out.println(br.readLine());
					
					System.out.println("wut");

				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} 
				
				System.out.println("Out");
			}
			else 
				System.out.println("File or layer thickness not initialized");
		}
		else
			System.out.println(System.getProperty("os.name")+" is not supported by freeSteel");
		

	}

}
