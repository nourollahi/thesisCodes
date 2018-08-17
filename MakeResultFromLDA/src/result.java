import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;


public class result {

	public static void main(String[]args) throws IOException {
		File file = new File("model-final.theta");
		FileReader fileReader = new FileReader(file);
		@SuppressWarnings("resource")
		BufferedReader bufferedReader = new BufferedReader(fileReader);
		
		System.out.println("arg0=topicNo arg1=docNo");
		int topicnumber=Integer.parseInt(args[0]);
		
		int docnumber=Integer.parseInt(args[1]);
		
		
		int[] index = new int[docnumber];
		
		
	for (int j=0;j<docnumber;++j)
	{
		String edge= bufferedReader.readLine();
		String[] parts = edge.split(" ");
		double largest = 0;
	
		double[] number = new double[topicnumber];
		for(int i =0;i<parts.length;i++) 
		{
			number[i]=Double.parseDouble(parts[i]);
			 if(number[i] > largest)
			 {
				 largest = number[i];
				 index[j]=i+1;
				 
			 }
		}
		System.out.println(index[j]);
	}
	
	
	////for proper result maker uncomment below lines.
	//result will created like sepehr requirement
for (int j=0;j<topicnumber;++j)
{
	for (int i=0;i<docnumber;++i)
	{
		if (index[i]==j+1)
		{
			System.out.print(i+1+" ");
		}
	}
	System.out.println();
}
	
	
	

	}

}
