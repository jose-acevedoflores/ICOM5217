package controller.lightcrafter;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

/**
 * Class for controlling the TI LightCrafter
 * @author hfranqui
 * Inspired in a code wrote by Jan Winter, TU Berlin, FG Lichttechnik 
 * j.winter@tu-berlin.de. Thanks!
 */


public class LightCrafterController {

	private DataOutputStream output;
	public static final int MAX_PACKET_SIZE = 512;
	public static final int MAX_PAYLOAD_LENGTH = 65535;

	
	/**
	 * Constructor for the LightCrafter control API
	 * @param output A DataOuputStream object given by the socket used to communicate with the LightCrafter.
	 */
	public LightCrafterController(DataOutputStream output) {	
		this.output = output;
	}

	/**
	 * Sets the display of the LightCrafter to static image display mode.
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setStaticImageDisplay() throws IOException {

		int[] command = new int[8];

		command[0] = 0x02; // packet type: write command
		command[1] = 0x01; // command byte 1
		command[2] = 0x01; // command byte 2
		command[3] = 0x00; // flags
		command[4] = 0x01; // paydata length LSB
		command[5] = 0x00; // paydata length MSB
		command[6] = 0x00; // data: set static
		command[7] = getChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);
		command = null; 
	}

	/**
	 * Sets the LightCrafter display mode to display the internal test patterns.
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setInternalPatternDisplay() throws IOException {

		int[] command = new int[8];

		command[0] = 0x02; // packet type: write command
		command[1] = 0x01; // command byte 1
		command[2] = 0x01; // command byte 2
		command[3] = 0x00; // flags
		command[4] = 0x01; // paydata length LSB
		command[5] = 0x00; // paydata length MSB
		command[6] = 0x01; // data: set pattern
		command[7] = getChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);
		command = null;

	}
	

	/**
	 * Sets the image to be displayed by the static image display mode.
	 * @param currentImageInt An integer array containing the bytes of the image.
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setStaticImageFile(int[] currentImageInt) throws IOException {

		// Create all chunks

		int start = 0;
		int end = currentImageInt.length;

		while (start < end) {
			System.out.println("Writing packet " + start);
			int[] test = new int[65535];


			int flags = 0x02;
			if (start == 0) {
				flags = 0x01;
			}

			test[0] = 0x02;
			test[1] = 0x01;
			test[2] = 0x05;
			test[3] = flags;
			test[4] = 0xF8;
			test[5] = 0xFF;

			int packetLength = 65528;
			if (start+65528 > end) {
				packetLength = end - start;
			}

			System.arraycopy(currentImageInt, start, test, 6, packetLength);

			test[65534] = getChecksum(test);

			for (int i = 0; i < test.length; i++) {
				output.write(test[i]);
			}

			start = start + 65528;

		}

	}


	/**
	 * Sets the LightCrafter to display the pattern sequence. 
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setPatternSequenceDisplay() throws IOException {

		int[] command = new int[8];

		command[0] = 0x02; // packet type: write command
		command[1] = 0x01; // command byte 1
		command[2] = 0x01; // command byte 2
		command[3] = 0x00; // flags
		command[4] = 0x01; // paydata length LSB
		command[5] = 0x00; // paydata length MSB
		command[6] = 0x04; // data: set pattern
		command[7] = getChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);
		command = null;
		
	}

	/**
	 * Sets up a pattern sequence of up to 1500 patterns in the LightCrafter.
	 * @param autoTrigger True if auto trigger is desired. False will set manual trigger.
	 * @param images A list of integer arrays, each integer array contains the byte of an image that is part of the pattern sequence.
	 * @param inputTriggerTime The time in micro seconds for the input trigger delay.
	 * @param exposureTime The time in micro seconds for the exposure time delay (how much an image is displayed)
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setPatternSequenceFiles(boolean autoTrigger, List<int[]> images, int inputTriggerTime, int exposureTime) throws IOException {

		// Get number of patterns
		int patternAmountLSB = images.size() % 256;
		int patternAmountMSB = (int) Math.floor(images.size() / 256);
		
		// Get exposure time
		int exposure1 = exposureTime % 256;
		int exposure2 = (exposureTime / 256) % 256;
		int exposure3 = exposureTime / 65536;
		int exposure4 = exposureTime / 16777215;
		
		// Get input trigger time
		int inputTime1 = exposureTime % 256;
		int inputTime2 = (exposureTime / 256) % 256;
		int inputTime3 = exposureTime / 65536;
		int inputTime4 = exposureTime / 16777215;
		
		// Set trigger type
		int triggerType = 0x00;
		if (autoTrigger)
			triggerType = 0x01;
		
		// Send pattern setup packet first
		int[] initCommand = new int[27];
		
		initCommand[0] = 0x02; // packet type: write command
		initCommand[1] = 0x04; // command byte 1
		initCommand[2] = 0x80; // command byte 2
		initCommand[3] = 0x00; // flags

		initCommand[4] = 0x14; // paydata length LSB
		initCommand[5] = 0x00; // paydata length MSB

		initCommand[6] = 0x08; // pattern bit depth
		initCommand[7] = patternAmountLSB; // number of patterns 1
		initCommand[8] = patternAmountMSB; // number of patterns 2
		initCommand[9] = 0x00; // patterns only (no inverted)
		initCommand[10] = triggerType; // trigger type: auto-trigger
		initCommand[11] = inputTime1; // input trigger delay 1
		initCommand[12] = inputTime2; // input trigger delay 2
		initCommand[13] = inputTime3; // input trigger delay 3
		initCommand[14] = inputTime4; // input trigger delay 4
		initCommand[15] = 0x40; // trigger signal period 1
		initCommand[16] = 0x1F; // trigger signal period 2
		initCommand[17] = 0x00; // trigger signal period 3
		initCommand[18] = 0x00; // trigger signal period 4 (about 8000 us)
		initCommand[19] = exposure1; // exposure period 1
		initCommand[20] = exposure2; // exposure period 2
		initCommand[21] = exposure3; // exposure period 3
		initCommand[22] = exposure4; // exposure period 4
		initCommand[23] = 0x00; // LED select?: red
		initCommand[24] = 0x00; // Play mode
		initCommand[25] = 0x00; // LED select?: red

		initCommand[26] = getChecksum(initCommand);

		// Send setup packet
		for (int i = 0; i < 27; i++) {
			output.write(initCommand[i]);
		}

		//For debug purposes
		//System.out.println("Initializing command sent");

		// Send patterns		
		for (int currentPattern = 0; currentPattern < images.size(); currentPattern++) {

			int[] currentImageInt = images.get(currentPattern);

			System.out.println("Image # " + currentPattern);

			int start = 0;
			int end = currentImageInt.length;

			while (start < end) {
				//System.out.println("Writing packet " + start);
				int[] test = new int[65535];


				int flags = 0x02;
				if (start == 0) {
					flags = 0x01;
				}

				test[0] = 0x02;
				test[1] = 0x04;
				test[2] = 0x81;
				test[3] = flags;
				test[4] = 0xF8;
				test[5] = 0xFF;
				
				test[6] = currentPattern;
				test[7] = 0x00;
				test[8] = 0x00;
				test[9] = 0x00;
				test[10] = 0x00;
				test[11] = 0x00;

				int packetLength = 65522;
				if (start+65522 > end) {
					packetLength = end - start;
					test[3] = 0x03;
				}

				System.arraycopy(currentImageInt, start, test, 12, packetLength);

				test[65534] = getChecksum(test);

				for (int i = 0; i < test.length; i++) {
					output.write(test[i]);
				}

				start = start + 65522;
			}

		}

	}

	/**
	 * Initiates a pattern sequence in the LightCrafter
	 * @throws IOException An exception thrown if there's any problem communicating with the LightCrafter.
	 */
	public void setPatternSequenceStart() throws IOException {

		List<Byte> command = new LinkedList<Byte>();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x04); // command byte 1
		command.add((byte) 0x02); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) 0x01); // paydata length LSB
		command.add((byte) 0x00); // paydata length MSB
		command.add((byte) 0x01); // data: set pattern
		addChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);
		
	}

	/**
	 * Converts a list to an array of bytes
	 * @param list
	 * @return
	 */
	public byte[] getByteArray(List<Byte> list) {
		byte[] result = new byte[list.size()];
		for (int i = 0; i < result.length; i++) {
			result[i] = list.get(i);
		}

		return result;
	}

	/**
	 * Send data to the LightCrafter. Sends packets of 512 bytes at a time.
	 * @param list A list containing all the bytes that are going to be sent.
	 * @throws IOException Throws an exception if the output stream for the
	 * LightCrafter faces a transmission error
	 */
	public void sendData(List<Byte> list) throws IOException {

		byte[] toSend = getByteArray(list);
		byte[] currentPacket = null;

		if (toSend.length > 512) {
			int currentPos = 0;

			System.out.println("Data length: " + toSend.length);

			while (currentPos < toSend.length) {

				// Create a new temp packet
				currentPacket = new byte[512];

				for (int i = currentPos; (i < (currentPos + MAX_PACKET_SIZE)); i++) {//&& (i < toSend.length); i++) {
					if (i < toSend.length) {
						currentPacket[i - currentPos] = toSend[i]; 
						//System.out.println(toSend[i]);
					}
					else {
						currentPacket[i - currentPos] = 0;
					}
				}
				currentPos = currentPos + 512;
				//System.out.println("Currentpos (packet): " + currentPos);

				output.write(currentPacket);
			}
		}
		else { 
			output.write(toSend);
		}

	}

	/**
	 * Transmits to LightCrafter the given integer array
	 * @param toSend Integer array containing the bytes of the packet
	 * @throws IOException Exception thrown if there's any problem communicating
	 * with the LightCrafter via the open socket.
	 */
	public void sendData(int[] toSend) throws IOException {
		
		for (int i = 0; i < toSend.length; i++) {
			output.write(toSend[i]);
		}

	}

	/**
	 * 
	 * @param partialPacket
	 */
	public void addChecksum(List<Byte> partialPacket) {

		int checksum = 0;
		for (byte b: partialPacket) {
			checksum = checksum + b;
		}

		byte checksumByte = (byte) (checksum % 512);
		partialPacket.add(checksumByte);

	}

	/**
	 * Calculates the checksum byte for the given packet
	 * @param partialPacket The packet used to calculate its checksum byte
	 * @return The checksum byte
	 */
	public int getChecksum(int[] partialPacket) {

		int checksum = 0;
		for (int b: partialPacket) {
			checksum = checksum + b;
		}

		return (checksum % 512);
	}

}
