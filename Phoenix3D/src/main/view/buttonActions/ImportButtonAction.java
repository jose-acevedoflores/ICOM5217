package main.view.buttonActions;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

import main.freesteel.FreeSteelSlice;
import main.view.MainFrame;

/**
 * This class will encapsulate the functionality of:
 * 1) getting the STL file the user wants to print 
 * 2) Making sure it exists 
 * 3) and invoking the FreeSteel Script that will slice the STL model to generate the images 
 * @author joseacevedo
 *
 */
public class ImportButtonAction implements ActionListener{

	private JFileChooser fileChooser;
	private FileNameExtensionFilter filter;
	private MainFrame viewReferences;
	private FreeSteelSlice sliceScript; 
	
	public ImportButtonAction(MainFrame frame)
	{
		viewReferences = frame;
		fileChooser = new JFileChooser();
		filter = new FileNameExtensionFilter("STL files", "stl", "STL");
		fileChooser.setFileFilter(filter);
		
		fileChooser.addActionListener(new UserSelectFile());
		
		sliceScript = new FreeSteelSlice(viewReferences);
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		
		fileChooser.showDialog(viewReferences, "Select");	
		
	}
	
	
	private class UserSelectFile implements ActionListener{

		@Override
		public void actionPerformed(ActionEvent action) {
		
			if(action.getActionCommand().equals(JFileChooser.APPROVE_SELECTION))
			{
				
				FreeSteelSlice.STL_FILE_NAME = fileChooser.getSelectedFile().getAbsolutePath();
				
				sliceScript.slice();
			}
			else if (action.getActionCommand().equals(JFileChooser.CANCEL_SELECTION))
			{
				System.out.println("Cancel");
			}
			
		}
		
	}

}
