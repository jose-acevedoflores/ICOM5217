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
			FileInputStream is;
			for(File f : freeSteelBMPs)
			{
				is = new FileInputStream(f);
				byte[] currentImageBytes = new byte[is.available()];
				int[] currentImageInt = new int[currentImageBytes.length];
				is.read(currentImageBytes);
				
				for(int i = 0 ; i < currentImageBytes.length; i++)
					currentImageInt[i] = currentImageBytes[i];
				
				list.add(currentImageInt);
			}
			System.out.println("Sending files: "+freeSteelBMPs.length);
			lcrController.setPatternSequenceFiles(true, list, 0, 250000);
			Thread.sleep(50);
			lcrController.setInternalPatternDisplay();
			Thread.sleep(50);
			lcrController.setPatternSequenceDisplay();
			Thread.sleep(100);
			lcrController.setPatternSequenceStart();
			
			
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
		
		System.out.println("print");
	}

}
