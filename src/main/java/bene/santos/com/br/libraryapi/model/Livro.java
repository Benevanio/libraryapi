package bene.santos.com.br.libraryapi.model;


import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "livro", schema = "public")
@Data
public class Livro {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id")
    private UUID id;

    @Column(name = "isbn", nullable = false, length = 20)
    private String isbn;

    @Column(name = "isbn", nullable = false, length = 150)
    private String titulo;

    @Column(name= "data_publicacao", nullable = false)
    private LocalDate   data_publicacao;

    @Enumerated(EnumType.STRING)
    @Column(name = "genero",  nullable = false, length = 30)
    private GeneroLivro genero;

    @Column(name = "preco", precision = 18, scale = 2)
    private Double  preco;

    @ManyToOne
    @JoinColumn(name= "autor_id")
    private Autor autor;
}
