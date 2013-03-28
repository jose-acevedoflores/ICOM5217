package main.view.buttonActions;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.net.Socket;

import controller.lightcrafter.LightCrafterController;

/**
 * 
 * @author jose
 *
 */
public class PrintButtonAction implements ActionListener{

	private LightCrafterController lcrController;
	private Socket socket;
	private File freeSteelBMPs;

	public PrintButtonAction(String freeSteelBmps)
	{
		this.freeSteelBMPs = new File(System.getProperty("user.dir") + "/"+freeSteelBmps);
		System.out.println(this.freeSteelBMPs.getAbsolutePath());
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		
		try{
			socket = new Socket("192.168.1.100", 21845);
			lcrController = new LightCrafterController(new DataOutputStream(socket.getOutputStream()) );
			
			
		} catch (IOException e1) {
			System.out.println("Error in socket");
			e1.printStackTrace();
		}
		
		System.out.println("print");
	}

}
