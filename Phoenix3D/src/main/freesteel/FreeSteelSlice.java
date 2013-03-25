package main.freesteel;

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


	private MainFrame viewReferences; 

	/**
	 * Creates a new FreeSteel Runtime component to access the Python script of FreeSteel
	 */
	public FreeSteelSlice(MainFrame frame)
	{
		viewReferences = frame;
	}

	/**
	 * This method slices the STL file in bmp images
	 */
	public void slice()
	{
		System.out.println(System.getProperty("os.name"));
		if(!System.getProperty("os.name").equals("Mac OS X"))
		{
			if(!STL_FILE_NAME.equals("!") )
			{
				System.out.println(STL_FILE_NAME+" -- "+LAYER_THICKNESS);
				//The substring here gets the original content of the JLabel (Number of layers:) and adds the new computed number of layers
				viewReferences.numOfLayers.setText(viewReferences.numOfLayers.getText().substring(0, 17)+ " 200");
			}
			else 
				System.out.println("File or layer thickness not initialized");
		}
		else
			System.out.println("Mac OS X is not supported by freeSteel");
		

	}

}
