import java.io.*;
import java.util.*;
import org.w3c.dom.*;
import javax.xml.parsers.*;
 
class Gitalk {
    public static String urls_path = "/Users/pengzhendong/Code/pengzhendong/utils/urls.txt";
    public static void collectURLs() throws Exception {
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder db = dbf.newDocumentBuilder();
        String path = "/Users/pengzhendong/Code/pengzhendong/utils/sitemap.xml";
        Document document = db.parse(path);
        NodeList urlList = document.getElementsByTagName("url");

        File writename = new File(urls_path);
		writename.createNewFile();
		BufferedWriter out = new BufferedWriter(new FileWriter(writename));

        List<String> urls = new ArrayList<>();
        for (int i = 0; i < urlList.getLength(); i++) {
            NodeList childNodes = urlList.item(i).getChildNodes();
            for (int k = 0; k < childNodes.getLength(); k++) {
                String nodeName = childNodes.item(k).getTextContent().trim();
                if ("loc".equals(childNodes.item(k).getNodeName())) {
                    urls.add(nodeName);
                }
            }
        }

        for (int i = urls.size() - 1; i >= 0; i--) {
            System.out.println(urls.get(i));
            out.write(urls.get(i) + "\n");
            out.flush();
        }
        out.close();
    }

    public static void initComment() throws Exception {
        BufferedReader in = new BufferedReader(new FileReader(urls_path));
        String url;
        while ((url = in.readLine()) != null) {
            if (url.equals("")) continue;
            Runtime.getRuntime().exec(new String[]{"/usr/bin/open", "-a", "/Applications/Google Chrome.app", url});
            Thread.sleep(3000);
        }
    }

    public static void main(String[] args) throws Exception {
        // collectURLs();
        initComment();
    }
}