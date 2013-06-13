package main.view.buttonActions;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.LinkedList;
import java.util.List;

import main.freesteel.FreeSteelSlice;
import controller.lightcrafter.LightCrafterController;

/**
 * 
 * @author jose
 *
 */
public class PrintButtonAction implements ActionListener{

	private LightCrafterController lcrController;
	private Socket socket;
	private File[] freeSteelBMPs;
	private boolean socketReady=false;

	public void ready(File[] orderedBmps)
	{
		this.freeSteelBMPs = orderedBmps;
	}

	@Override
	public void actionPerformed(ActionEvent e) {



		try{
			Thread t = new Thread(new Runnable() {

				@Override
				public void run() {
					try {
						socket = new Socket("192.168.1.100", 21845);

						lcrController = new LightCrafterController(new DataOutputStream(socket.getOutputStream()) );
						socketReady = true;
					} catch (UnknownHostException e) {
						System.out.println("No Host found");
						e.printStackTrace();

					} 
					catch (SocketException e2) {
						System.out.println("Time Out reached");
					}
					catch (IOException e) {
						System.out.println("Error in connection");
						e.printStackTrace();
					}
				}
			});

			System.out.println("Initializing LCr socket");
			t.start();
			System.out.println("Waiting");

			Thread.sleep(1000);

			if(!socketReady)
			{
				System.out.println("Printer Not Connected");
				System.out.println("Thread alive "+t.isAlive());
				//TODO maybe kill Thread ????????
				return;
			}

			System.out.println("Socket on ");

			List<int[]> list = new LinkedList<int[]>();
			FileInputStream is = null;

			//Save support layers
			is = new FileInputStream(new File(System.getProperty("user.dir")+"/resources/supportLayers1.bmp"));
			byte[] currentImageBytes = new byte[is.available()];
			int[] currentImageInt = new int[currentImageBytes.length];			
			is.read(currentImageBytes);
			
			for(int i = 0 ; i < currentImageBytes.length; i++)
				currentImageInt[i] = currentImageBytes[i];
			
			list.add(currentImageInt);

			for(File f : freeSteelBMPs)
			{
				is = new FileInputStream(f);
				currentImageBytes = new byte[is.available()];
				currentImageInt = new int[currentImageBytes.length];
				is.read(currentImageBytes);

				for(int i = 0 ; i < currentImageBytes.length; i++)
					currentImageInt[i] = currentImageBytes[i];

				list.add(currentImageInt);
			}
			System.out.println("Sending files: "+freeSteelBMPs.length);
			lcrController.setPatternSequenceFiles(false, list, 10, 20000);
			Thread.sleep(50);
			lcrController.setInternalPatternDisplay();
			Thread.sleep(50);
			lcrController.setPatternSequenceDisplay();
			Thread.sleep(100);
			lcrController.setPatternSequenceStart();

			sendDataToMicroProcessor();

			// Additions begin here - code for controlling LightCrafter during
			// printing operation

			// Display first image in the sequence
			lcrController.advancePatternSequence();

			//TODO: Check correct resin dry times for the adequate layer thickness
			long resinDryTime = 601000;
			//long resinDryTime = 10000;
			
			if (FreeSteelSlice.LAYER_THICKNESS == 1.5) {
				resinDryTime = 1801000;
			}
			else if (FreeSteelSlice.LAYER_THICKNESS == 1.0) {
				resinDryTime = 1201000;
			}

			long startUpTime = 1201000 - resinDryTime;

			// Wait some time for the micro procesor
			Thread.sleep(1000);
			
			int currentLayer = 0;
			while (currentLayer < list.size()) {

				// Wait 10 minutes for each layer
				if (currentLayer == 0) {
					// For debug purposes
					Thread.sleep(startUpTime);
				}

				Thread.sleep(resinDryTime);
				//Thread.sleep(10000);

				System.out.println("Printing layer " + currentLayer + " of " + list.size());

				currentLayer++;
				lcrController.advancePatternSequence();

			}

			System.out.println("Done printing...");
			is.close();


		} catch (IOException e1) {
			e1.printStackTrace();
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}
		finally{
			try {
				if(socket != null)
					socket.close();
			} catch (IOException e1) {
				e1.printStackTrace();
			}
		}

	}

	private void sendDataToMicroProcessor() {
		// Additions begin here
		// Send printing information to the microprocessor

		String editedFileName = FreeSteelSlice.STL_FILE_NAME.substring(FreeSteelSlice.STL_FILE_NAME.lastIndexOf(File.separator)+1, FreeSteelSlice.STL_FILE_NAME.lastIndexOf('.'));

		Process p = null;

		String prefix = "";
		String suffix = ".exe";

		//TODO: Add support for Mac OSX
		// Add support for executing Linux binaries
		if (System.getProperty("os.name").equals("Linux")) {
			prefix = "./";
			suffix = "";
		}
				String programName = prefix + "serialport" + suffix;
				String programLocation = System.getProperty("user.dir") + File.separator + "resources" + File.separator + "SerialComm" + File.separator;
				String information = "<>"+Integer.toString(freeSteelBMPs.length) + "," + Double.toString(FreeSteelSlice.LAYER_THICKNESS) + "," + editedFileName + "`";


		//String programName = prefix + "serialport" + suffix;
		//String programLocation = System.getProperty("user.dir") + File.separator + "resources" + File.separator + "SerialComm" + File.separator;
		//String information = "<>" + Integer.toString(freeSteelBMPs.length) + "," + Double.toString(FreeSteelSlice.LAYER_THICKNESS) + "," + editedFileName + "`";

		System.out.println("Information to send to the microprocessor: " + information);

		String cmd[] = {programName, information};
		String envp[] = {""};

		try {
			p = Runtime.getRuntime().exec(cmd, envp, new File(programLocation));
		} catch (IOException e1) {
			System.out.println("There was a problem trying to execute the serial port communication program.");
			e1.printStackTrace();
		}
		// Eliminates warning
		p.getErrorStream();

		try {
			int status = p.waitFor();
			if (status == 0) {
			}
			p.destroy();
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}

		System.out.println("print");
	}

}
