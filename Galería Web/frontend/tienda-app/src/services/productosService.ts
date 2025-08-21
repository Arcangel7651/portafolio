import axios from "axios";
import { Producto } from "../models/Producto";

const API_URL = "http://127.0.0.1:8000/api/v1"; // tu IP local

export const getProductos = async (): Promise<Producto[]> => {
  const res = await axios.get(`${API_URL}/productos/`);
   return res.data.results;
};
