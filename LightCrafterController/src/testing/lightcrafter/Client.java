package testing.lightcrafter;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;

import javax.swing.JFileChooser;
import controller.lightcrafter.LightCrafterController;

public class Client {

	public static Socket socket;
	public static DataOutputStream out;
	public static BufferedReader in;

	/**
	 * @param args
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public static void main(String[] args) throws IOException, InterruptedException {

		initiateSocket();

		Scanner stdIn = new Scanner(System.in);

		LightCrafterController controller = new LightCrafterController(out);

		JFileChooser chooser = new JFileChooser();
		chooser.setCurrentDirectory(new File("/media/disk/Documents and Settings/Héctor/Documents/RUM/Cuarto Año (2012-2013)/ICOM 5217/Development"));
		chooser.setMultiSelectionEnabled(true);
		chooser.showOpenDialog(null);
		
		File[] files = chooser.getSelectedFiles();
		
		List<int[]> list = new LinkedList<int[]>();
		
		for (File f: files) {
			FileInputStream is = new FileInputStream(f);

			byte[] currentImageBytes = new byte[is.available()];
			int[] currentImageInt = new int[currentImageBytes.length];

			is.read(currentImageBytes);

			for (int i = 0; i < currentImageBytes.length; i++) {
				currentImageInt[i] = currentImageBytes[i];
			}
			list.add(currentImageInt);
		}
		
		System.out.println(list.size());
		
		controller.setPatternSequenceFiles(true, list, 0, 250000);
		
		Thread.sleep(50);
		
		controller.setInternalPatternDisplay();

		Thread.sleep(50);
		
		controller.setPatternSequenceDisplay();
		
		Thread.sleep(100);
		
		controller.setPatternSequenceStart();

		out.close();
		in.close();
		stdIn.close();
		socket.close();

	}

	public static void initiateSocket() {
		socket = null;
		out = null;
		in = null;

		try {
			socket = new Socket("192.168.1.100", 0x5555);
			out = new DataOutputStream(socket.getOutputStream());
			in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		} catch (UnknownHostException e) {
			System.err.println("Don't know about host: localhost.");
			System.exit(1);
		} catch (IOException e) {
			System.err.println("Couldn't get I/O for the connection to: taranis.");
			System.exit(1);
		}

	}


}
