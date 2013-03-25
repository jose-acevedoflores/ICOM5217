package main.view.buttonActions;

import java.awt.Component;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

/**
 * This class will encapsulate the functionality of:
 * 1) getting the STL file the user wants to print 
 * 2) Making sure it exists 
 * 3) and invoking the FreeSteel Script that will slice the STL model to generate the images 
 * @author joseacevedo
 *
 */
public class ImportButtonAction implements ActionListener{

	JFileChooser fileChooser;
	FileNameExtensionFilter filter;
	Component comp;
	
	public ImportButtonAction(Component frame)
	{
		comp = frame;
		fileChooser = new JFileChooser();
		filter = new FileNameExtensionFilter("STL files", "stl", "STL");
		fileChooser.setFileFilter(filter);
		
		fileChooser.addActionListener(new UserSelectFile());
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		
		fileChooser.showDialog(comp, "Select");	
		
	}
	
	
	private class UserSelectFile implements ActionListener{

		@Override
		public void actionPerformed(ActionEvent action) {
		
			if(action.getActionCommand().equals(JFileChooser.APPROVE_SELECTION))
			{
				
				File userSelectedFile = fileChooser.getSelectedFile();
				
				userSelectedFile.getAbsolutePath();
				
			}
			else if (action.getActionCommand().equals(JFileChooser.CANCEL_SELECTION))
			{
				System.out.println("Cancel");
			}
			
		}
		
	}

}
