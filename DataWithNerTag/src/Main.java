import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

public class Main {

	public static void main(String[] args) throws IOException {
		try {
			
			Scanner sc = new Scanner(new File("input/DadashTrecFormat-out.txt"));
			AllTermsTag(sc);
//			justNEs( sc);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	private static void justNEs (Scanner sc) throws IOException {
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("output/justNE.txt")));
		StringBuilder sb = new StringBuilder();
		while (sc.hasNextLine()) {

			String line = sc.nextLine();
			if (line.contains("DocID")) {
				bw.write(sb.toString());
				bw.newLine();
				sb.setLength(0);
			} else {
				if (!(line.contains("O"))) {
					sb.append(line + ";");
				}
			}
		}
		sc.close();
		//bw.close();
		System.out.println("done");
	}



	private static void AllTermsTag(Scanner sc) throws IOException {
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("output/DadashiWithNETags.txt")));
		StringBuilder sb = new StringBuilder();
		while (sc.hasNextLine()) {

			String line = sc.nextLine();
			if (line.contains("DocID")) {
				// write sb
				bw.write(sb.toString());
				bw.newLine();
				sb.setLength(0);
			} else {
				sb.append(line + ";");
			}
		}
		sc.close();
		bw.close();
		System.out.println("done");
	}

}

