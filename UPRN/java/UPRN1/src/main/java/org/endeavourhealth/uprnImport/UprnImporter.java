package org.endeavourhealth.uprnImport;

import java.util.Properties;
import java.io.IOException;
import java.sql.SQLException;
import java.io.InputStream;
import org.endeavourhealth.uprnImport.routines.*;
import org.endeavourhealth.uprnImport.routines.UprnMySQL.*;

public class UprnImporter {
	public static void main(String... args) throws IOException, SQLException {

        Properties properties = loadProperties( args );

        // Gill's ABP stuff
        if (args.length>=1 && args[0].equalsIgnoreCase("ABP")) {
            try ( UprnMySQL z = new UprnMySQL(properties) ) {
                z.IMPABP();
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }

        // TEST
        if (args.length>=1 && args[0].equalsIgnoreCase("DICTION")) {
            System.out.println("DICTION");
            try ( UprnMySQL z = new UprnMySQL(properties) ) {
                z.UPRNS();
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }

        if (args.length>=1 && args[0].equalsIgnoreCase("TEST")) {
            System.out.println("TEST");
            try ( UprnMySQL z = new UprnMySQL(properties) ) {
                z.Test();
            }
            catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
            System.exit(0);
        }

        if (args.length>=1 && args[0].equalsIgnoreCase("EXPORT")) {
            System.out.println(args[0]);
            // filename
            System.out.println(args[1]);
            String filename = args[1];

            //export.Classiication(filename);
            export.IMPCLASS("D:\\TEMP\\UPRN-BASE\\");
        }

        if (args.length>=1 && args[0].equalsIgnoreCase("IMPORT")) {
            try ( UprnMySQL z = new UprnMySQL(properties) ) {

                //z.Test(); COMMENTED OUT

                //z.LoadClassification();
                //z.IMPCLASS();
                //z.IMPSTR();
                //z.IMPBLP2();

                // not used (do not run this)
                //z.IMPUPC(); COMMENTED OUT

                //z.IMPDPA();
                //z.UPRNS();
                //z.IMPLPI();
                //z.UPRNIND();

                // Dictionary stuff
                //z.AREAS();
                z.TOWNS();

                // populates ABP data
                //z.TurnIntoTab();
            } catch (Exception e) {
                System.out.println(e);
                e.printStackTrace();
            }
        }
	}

    private static Properties loadProperties(String[] args) throws IOException {

        Properties properties = new Properties();

        InputStream inputStream = UprnImporter.class.getClassLoader().getResourceAsStream("uprn.importer.properties");

        properties.load( inputStream );

        return properties;
    }
}